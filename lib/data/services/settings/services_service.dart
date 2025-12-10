import 'dart:developer' as dev;
import 'dart:convert';
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/service_dto.dart';

class ServicesService extends ApiBase {
  Future<List<ServiceDto>> fetchAll() async {
    final uri = buildUri(Endpoints.services);
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(() => httpClient.get(uri, headers: headers));

    final decoded = HttpErrorHandler.handleListResponse(response, 'Failed to load services');

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      // ignore: curly_braces_in_flow_control_structures
      } else if (decoded['services'] is List) list = decoded['services'] as List;
    }
    list ??= const [];

    return ServiceDto.fromJsonList(list);
  }

  Future<ServiceDto> store(Map<String, dynamic> payload) async {
    final uri = buildUri(Endpoints.services);
    final headers = await buildHeaders();

    dev.log('[HTTP] POST $uri payload=${jsonEncode(payload)}');

    final response = await HttpErrorHandler.executeRequest(() => httpClient.post(uri, headers: headers, body: jsonEncode(payload)));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to create service');

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) return ServiceDto.fromJson(decoded['data'] as Map<String, dynamic>);
      return ServiceDto.fromJson(decoded);
    }

    throw Exception('Unexpected response format');
  }

  Future<ServiceDto> show(int id) async {
    final uri = buildUri(Endpoints.serviceById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(() => httpClient.get(uri, headers: headers));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to load service');

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) return ServiceDto.fromJson(decoded['data'] as Map<String, dynamic>);
      return ServiceDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<ServiceDto> update(int id, Map<String, dynamic> payload) async {
    final uri = buildUri(Endpoints.serviceById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] PATCH $uri payload=${jsonEncode(payload)}');

    final response = await HttpErrorHandler.executeRequest(() => httpClient.patch(uri, headers: headers, body: jsonEncode(payload)));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to update service');

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) return ServiceDto.fromJson(decoded['data'] as Map<String, dynamic>);
      return ServiceDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<void> destroy(int id) async {
    final uri = buildUri(Endpoints.serviceById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');

    final response = await HttpErrorHandler.executeRequest(() => httpClient.delete(uri, headers: headers));

    HttpErrorHandler.handleResponse(response, 'Failed to delete service');
  }
}
