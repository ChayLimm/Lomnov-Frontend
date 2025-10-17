import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app/domain/models/building_model.dart';
import 'package:app/domain/services/buildings/api_base.dart';

class BuildingMutationService extends ApiBase {
  Future<void> deleteBuilding(int id) async {
    final uri = buildUri('/api/buildings/$id');
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');
    http.Response response;
    try {
      response = await httpClient
          .delete(uri, headers: headers)
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

    if (status == 204 || (status >= 200 && status < 300)) {
      return;
    }

    String message = 'Failed to delete building';
    try {
      if (bodyStr.isNotEmpty &&
          ((response.headers['content-type'] ?? '').contains('application/json') ||
              bodyStr.startsWith('{') ||
              bodyStr.startsWith('['))) {
        final decoded = jsonDecode(bodyStr);
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] is String) {
            message = decoded['message'];
          } else if (decoded['error'] is String) {
            message = decoded['error'];
          }
        }
      }
    } catch (_) {}
    throw Exception(message);
  }

  Future<BuildingModel> updateBuilding({
    required int id,
    int? landlordId,
    String? name,
    String? address,
    String? imageUrl,
    int? floor,
    int? unit,
  }) async {
    final uri = buildUri('/api/buildings/$id');
    final headers = await buildHeaders();

    final payload = <String, dynamic>{};
    void addIfNonNull(String key, dynamic value) {
      if (value != null) payload[key] = value;
    }
    addIfNonNull('landlord_id', landlordId);
    addIfNonNull('name', name);
    addIfNonNull('address', address);
    addIfNonNull('image_url', imageUrl);
    addIfNonNull('floor', floor);
    addIfNonNull('unit', unit);

    dev.log('[HTTP] PUT $uri body=${jsonEncode(payload)}');
    http.Response response;
    try {
      response = await httpClient
          .put(uri, headers: headers, body: jsonEncode(payload))
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
    } else if ((response.headers['content-type'] ?? '').contains('application/json') ||
        bodyStr.startsWith('{') || bodyStr.startsWith('[')) {
      try {
        decoded = jsonDecode(bodyStr);
      } catch (e) {
        dev.log('JSON decode failed: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception('Unexpected non-JSON response from server');
    }

    if (status >= 200 && status < 300) {
      if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is Map<String, dynamic>) {
          return BuildingModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return BuildingModel.fromJson(decoded);
      }
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        return BuildingModel.fromJson(decoded.first as Map<String, dynamic>);
      }
      throw Exception('Unexpected response format');
    }

    String message = 'Failed to update building';
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String) {
        message = decoded['message'];
      } else if (decoded['error'] is String) {
        message = decoded['error'];
      } else if (decoded['errors'] is Map<String, dynamic>) {
        final errors = (decoded['errors'] as Map<String, dynamic>)
            .values
            .expand((v) => v is List ? v : [v])
            .join('\n');
        if (errors.isNotEmpty) message = errors;
      }
    }
    throw Exception(message);
  }

  Future<BuildingModel> createBuilding({
    int? landlordId,
    required String name,
    required String address,
    String? imageUrl,
    required int floor,
    required int unit,
  }) async {
    final uri = buildUri('/api/buildings');
    final headers = await buildHeaders();

    final payload = <String, dynamic>{
      'name': name,
      'address': address,
      'image_url': imageUrl ?? '',
      'floor': floor,
      'unit': unit,
    };
    final landlord = landlordId ?? await auth.getLandlordId();
    if (landlord != null) payload['landlord_id'] = landlord;

    dev.log('[HTTP] POST $uri body=${jsonEncode(payload)}');
    http.Response response;
    try {
      response = await httpClient
          .post(uri, headers: headers, body: jsonEncode(payload))
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
    } else if ((response.headers['content-type'] ?? '').contains('application/json') ||
        bodyStr.startsWith('{') || bodyStr.startsWith('[')) {
      try {
        decoded = jsonDecode(bodyStr);
      } catch (e) {
        dev.log('JSON decode failed: $e');
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception('Unexpected non-JSON response from server');
    }

    if (status >= 200 && status < 300) {
      if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is Map<String, dynamic>) {
          return BuildingModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return BuildingModel.fromJson(decoded);
      }
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        return BuildingModel.fromJson(decoded.first as Map<String, dynamic>);
      }
      throw Exception('Unexpected response format');
    }

    String message = 'Failed to create building';
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String) {
        message = decoded['message'];
      } else if (decoded['error'] is String) {
        message = decoded['error'];
      } else if (decoded['errors'] is Map<String, dynamic>) {
        final errors = (decoded['errors'] as Map<String, dynamic>)
            .values
            .expand((v) => v is List ? v : [v])
            .join('\n');
        if (errors.isNotEmpty) message = errors;
      }
    }
    throw Exception(message);
  }
}
