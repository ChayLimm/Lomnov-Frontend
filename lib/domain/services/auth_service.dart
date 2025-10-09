import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  late final String _baseUrl = _normalizeBaseUrl(dotenv.env['BASE_URL'] ?? '');

  // Public API --------------------------------------------------------------
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async =>
      _postJson('/api/register', data, fallbackError: 'Registration failed');

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async =>
      _postJson('/api/login', data, fallbackError: 'Login failed');

  // Core HTTP helper -------------------------------------------------------
  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> data, {
    required String fallbackError,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    dev.log('[HTTP] POST $uri body=${jsonEncode(data)}');
    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
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
      // Some endpoints (esp. failures) may return no body.
      decoded = <String, dynamic>{};
    } else {
      decoded = _tryDecodeJson(bodyStr);
    }

    if (status >= 200 && status < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      // Unexpected non-map success payload.
      return {'raw': decoded};
    }

    // Error branch
    final message = _extractMessage(decoded, fallbackError);
    throw Exception(message);
  }

  // Helpers ----------------------------------------------------------------
  dynamic _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      // Return raw body so caller can still surface something meaningful.
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
        // Possibly HTML or plain text error.
        return decoded['raw'];
      }
    }
    return fallback;
  }

  String _normalizeBaseUrl(String input) {
    var url = input.trim();
    if (url.isEmpty) {
      throw Exception('BASE_URL is not set. Add BASE_URL to your .env');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // Assume https for ngrok free domain; change if backend only serves http.
      url = 'https://$url';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }
}
