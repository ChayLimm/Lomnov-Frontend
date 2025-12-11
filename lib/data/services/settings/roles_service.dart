import 'dart:convert';
import 'dart:developer' as dev;
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/role_dto.dart';

class RolesService extends ApiBase {
  Future<List<RoleDto>> fetchAll() async {
    final uri = buildUri(Endpoints.roles);
    final headers = await buildHeaders();
    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );
    final decoded = HttpErrorHandler.handleListResponse(response, 'Failed to load roles');
    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      }
    }
    list ??= const [];
    return RoleDto.fromJsonList(list);
  }

  Future<RoleDto> store(String roleName) async {
    final uri = buildUri(Endpoints.roles);
    final headers = await buildHeaders();
    final payload = {'role_name': roleName};
    dev.log('[HTTP] POST $uri payload=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );
    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to create role');
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return RoleDto.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return RoleDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<RoleDto> show(int id) async {
    final uri = buildUri(Endpoints.roleById(id));
    final headers = await buildHeaders();
    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );
    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to load role');
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return RoleDto.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return RoleDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<RoleDto> update(int id, String roleName) async {
    final uri = buildUri(Endpoints.roleById(id));
    final headers = await buildHeaders();
    final payload = {'role_name': roleName};
    dev.log('[HTTP] PATCH $uri payload=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.patch(uri, headers: headers, body: jsonEncode(payload)),
    );
    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to update role');
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return RoleDto.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return RoleDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<void> destroy(int id) async {
    final uri = buildUri(Endpoints.roleById(id));
    final headers = await buildHeaders();
    dev.log('[HTTP] DELETE $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
    );
    HttpErrorHandler.handleDeleteResponse(response, 'Failed to delete role');
  }
}