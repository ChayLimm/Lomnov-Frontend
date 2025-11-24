import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/data/endpoint/endpoints.dart';

class AuthService {

  // Persisted auth token (secure)
  static const _tokenKey = 'auth_token';
  static const _landlordIdKey = 'landlord_id';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Public API --------------------------------------------------------------
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async =>
    _postJson(Endpoints.register, data, fallbackError: 'Registration failed');

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async =>
    _postJson(Endpoints.login, data, fallbackError: 'Login failed');

  Future<void> logout() => _clearToken();
  /// Read token from secure storage with a short timeout and safe error handling.
  ///
  /// Rapid UI interactions (many concurrent requests/navigation) can surface
  /// platform-channel races or delays; we defend by timing out and returning
  /// null so callers treat the user as logged out rather than hanging the app.
  Future<String?> getToken() async {
    try {
      // Use a small timeout to avoid long stalls caused by platform channel delays
      return await _storage.read(key: _tokenKey).timeout(const Duration(seconds: 2));
    } catch (e, st) {
      dev.log('AuthService.getToken failed: $e', error: e, stackTrace: st);
      return null;
    }
  }

  Future<bool> isLoggedIn() async => (await getToken())?.isNotEmpty == true;

  // Landlord ID helpers
  Future<void> setLandlordId(int? id) async {
    if (id == null) return;
    await _storage.write(key: _landlordIdKey, value: id.toString());
  }

  Future<int?> getLandlordId() async {
    final v = await _storage.read(key: _landlordIdKey);
    if (v == null) return null;
    return int.tryParse(v);
  }

  // Core HTTP helper -------------------------------------------------------
  // Limit concurrent outgoing HTTP requests to avoid overwhelming the
  // platform channel / backend when the UI fires many quick taps.
  final int _maxConcurrentRequests = 4;
  int _activeRequests = 0;
  final List<Completer<void>> _requestQueue = [];

  Future<void> _acquireRequestSlot() async {
    if (_activeRequests < _maxConcurrentRequests) {
      _activeRequests++;
      return;
    }
    final c = Completer<void>();
    _requestQueue.add(c);
    await c.future;
    // when resumed, we've been counted in release
    return;
  }

  void _releaseRequestSlot() {
    _activeRequests = (_activeRequests - 1).clamp(0, _maxConcurrentRequests);
    if (_requestQueue.isNotEmpty) {
      final next = _requestQueue.removeAt(0);
      // increment activeRequests for the waiter before completing so it can proceed
      _activeRequests++;
      next.complete();
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> data, {
    required String fallbackError,
  }) async {
  final uri = Endpoints.uri(path);
    await _acquireRequestSlot();
    try {
      // Attach token if present. Protect against storage read failures by
      // treating a read failure as missing token (no Authorization header).
      final headers = <String, String>{'Content-Type': 'application/json'};
      try {
        final existingToken = await getToken();
        if (existingToken != null && existingToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $existingToken';
        }
      } catch (e, st) {
        dev.log('Failed to obtain token for request: $e', error: e, stackTrace: st);
      }

      // Redact sensitive values from logs
      dev.log('[HTTP] POST $uri body=${jsonEncode(_redact(data))}');
      http.Response response;
      try {
        response = await http
            .post(
              uri,
              headers: headers,
              body: jsonEncode(data),
            )
            .timeout(const Duration(seconds: 20));
      } on TimeoutException {
        throw Exception('Request timeout – please try again');
      } on SocketException {
        throw Exception('No internet connection');
      } on HttpException {
        throw Exception('HTTP error communicating with server');
      } on FormatException {
        throw Exception('Bad response format from server');
      }

      final status = response.statusCode;
      final bodyStr = response.body.trim();
      dev.log('[HTTP] <- $status ${bodyStr.isEmpty ? '<empty body>' : bodyStr}');

      dynamic decoded;
      if (bodyStr.isEmpty) {
        decoded = <String, dynamic>{};
      } else {
        decoded = _tryDecodeJson(bodyStr);
      }

      if (status >= 200 && status < 300) {
        if (decoded is Map<String, dynamic>) {
          // Auto-persist token if present
          final newToken = _extractToken(decoded);
          if (newToken != null && newToken.isNotEmpty) {
            await _saveToken(newToken);
          }
          // Auto-persist landlord_id if present
          final landlordId = _extractLandlordId(decoded);
          if (landlordId != null) {
            await setLandlordId(landlordId);
          }
          return decoded;
        }
        return {'raw': decoded};
      }

      final message = _extractMessage(decoded, fallbackError);
      throw Exception(message);
    } finally {
      _releaseRequestSlot();
    }
  }

  // Helpers ----------------------------------------------------------------
  dynamic _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      dev.log('JSON decode failed: $e');
      return {'raw': body};
    }
  }

  String _extractMessage(dynamic decoded, String fallback) {
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String) return decoded['message'];
      if (decoded['error'] is String) return decoded['error'];
      if (decoded['errors'] is Map<String, dynamic>) {
        return (decoded['errors'] as Map<String, dynamic>).values
            .expand((v) => v is List ? v : [v])
            .join('\n');
      }
      if (decoded['raw'] is String && decoded['raw'].toString().isNotEmpty) {
        return decoded['raw'];
      }
    }
    return fallback;
  }

  // Common token shapes
  String? _extractToken(Map<String, dynamic> json) {
    if (json['token'] is String) return json['token'] as String;
    if (json['access_token'] is String) return json['access_token'] as String;
    if (json['data'] is Map && (json['data']['token'] is String)) {
      return json['data']['token'] as String;
    }
    return null;
  }

  // Extract landlord_id from common response shapes
  int? _extractLandlordId(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v is int
        ? v
        : (v is String ? int.tryParse(v) : null);

    int? tryGet(Map<String, dynamic> m) {
      // Direct landlord fields
      final l1 = asInt(m['landlord_id']) ?? asInt(m['landlordId']);
      if (l1 != null) return l1;

      // From user object
      if (m['user'] is Map<String, dynamic>) {
        final u = m['user'] as Map<String, dynamic>;
        final l2 = asInt(u['landlord_id']) ?? asInt(u['landlordId']);
        if (l2 != null) return l2;
        // Fallback: use user.id as landlord_id
        final uid = asInt(u['id']);
        if (uid != null) return uid;
      }

      // From data wrapper
      if (m['data'] is Map<String, dynamic>) {
        final d = m['data'] as Map<String, dynamic>;
        final l3 = asInt(d['landlord_id']) ?? asInt(d['landlordId']);
        if (l3 != null) return l3;
        if (d['user'] is Map<String, dynamic>) {
          final u = d['user'] as Map<String, dynamic>;
          final l4 = asInt(u['landlord_id']) ?? asInt(u['landlordId']);
          if (l4 != null) return l4;
          final uid = asInt(u['id']);
          if (uid != null) return uid;
        }
        // Fallback: use data.id
        final did = asInt(d['id']);
        if (did != null) return did;
      }

      // Absolute fallback: top-level id
      final idTop = asInt(m['id']);
      if (idTop != null) return idTop;

      return null;
    }

    return tryGet(json);
  }

  Future<void> _saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<void> _clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _landlordIdKey);
    } catch (e, st) {
      dev.log('Failed to clear secure storage: $e', error: e, stackTrace: st);
    }
  }

  Map<String, dynamic> _redact(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    for (final k in ['password', 'pass', 'password_confirmation']) {
      if (copy.containsKey(k)) copy[k] = '***';
    }
    return copy;
  }
}