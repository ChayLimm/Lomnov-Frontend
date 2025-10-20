import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app/domain/models/building_model.dart';
import 'package:app/domain/services/buildings/api_base.dart';

class BuildingFetchService extends ApiBase {
  Future<List<BuildingModel>> fetchBuildings() async {
    final uri = buildUri('/api/buildings');
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    http.Response response;
    try {
      response = await httpClient
          .get(uri, headers: headers)
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

    final contentType = response.headers['content-type'] ?? '';
    dynamic decoded;
    if (bodyStr.isEmpty) {
      decoded = [];
    } else if (contentType.contains('application/json') ||
        bodyStr.startsWith('{') ||
        bodyStr.startsWith('[')) {
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
      List<dynamic>? list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is List) {
          list = decoded['data'] as List;
        } else if (decoded['buildings'] is List) {
          list = decoded['buildings'] as List;
        }
      }
      list ??= const [];
      return BuildingModel.fromJsonList(list);
    }

    String message = 'Failed to load buildings';
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String) {
        message = decoded['message'];
      } else if (decoded['error'] is String) {
        message = decoded['error'];
      }
    }
    throw Exception(message);
  }

  Future<List<BuildingModel>> fetchBuildingsByLandlord(int landlordId) async {
    // Use query filter against buildings endpoint to scope by landlord
    final uri = buildUri('/api/buildings?landlord_id=$landlordId');
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    http.Response response;
    try {
      response = await httpClient
          .get(uri, headers: headers)
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

    final contentType = response.headers['content-type'] ?? '';
    dynamic decoded;
    if (bodyStr.isEmpty) {
      decoded = [];
    } else if (contentType.contains('application/json') ||
        bodyStr.startsWith('{') ||
        bodyStr.startsWith('[')) {
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
      List<dynamic>? list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is List) {
          list = decoded['data'] as List;
        } else if (decoded['buildings'] is List) {
          list = decoded['buildings'] as List;
        }
      }
      list ??= const [];
      return BuildingModel.fromJsonList(list);
    }

    String message = 'Failed to load buildings';
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String) {
        message = decoded['message'];
      } else if (decoded['error'] is String) {
        message = decoded['error'];
      }
    }
    throw Exception(message);
  }

  Future<BuildingModel> fetchBuildingById(int id) async {
    final uri = buildUri('/api/buildings/$id');
    final headers = await buildHeaders();
    dev.log('[HTTP] GET $uri');
    http.Response response;
    try {
      response = await httpClient.get(uri, headers: headers).timeout(const Duration(seconds: 20));
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

    String message = 'Failed to load building';
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String) {
        message = decoded['message'];
      } else if (decoded['error'] is String) {
        message = decoded['error'];
      }
    }
    throw Exception(message);
  }
}
