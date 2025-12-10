import 'dart:convert';
import 'dart:developer' as dev;
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/room_type_dto.dart';

class RoomTypesService extends ApiBase {
  Future<List<RoomTypeDto>> fetchAll() async {
    final uri = buildUri(Endpoints.roomTypes);
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(() => httpClient.get(uri, headers: headers));

    final decoded = HttpErrorHandler.handleListResponse(response, 'Failed to load room types');

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      // ignore: curly_braces_in_flow_control_structures
      } else if (decoded['room_types'] is List) list = decoded['room_types'] as List;
    }
    list ??= const [];
    return RoomTypeDto.fromJsonList(list);
  }

  Future<RoomTypeDto> store(Map<String, dynamic> payload) async {
    final uri = buildUri(Endpoints.roomTypes);
    final headers = await buildHeaders();

    dev.log('[HTTP] POST $uri payload=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(() => httpClient.post(uri, headers: headers, body: jsonEncode(payload)));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to create room type');

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) return RoomTypeDto.fromJson(decoded['data'] as Map<String, dynamic>);
      return RoomTypeDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<RoomTypeDto> show(int id) async {
    final uri = buildUri(Endpoints.roomTypeById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(() => httpClient.get(uri, headers: headers));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to load room type');

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) return RoomTypeDto.fromJson(decoded['data'] as Map<String, dynamic>);
      return RoomTypeDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<RoomTypeDto> update(int id, Map<String, dynamic> payload) async {
    final uri = buildUri(Endpoints.roomTypeById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] PATCH $uri payload=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(() => httpClient.patch(uri, headers: headers, body: jsonEncode(payload)));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to update room type');

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) return RoomTypeDto.fromJson(decoded['data'] as Map<String, dynamic>);
      return RoomTypeDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  Future<void> destroy(int id) async {
    final uri = buildUri(Endpoints.roomTypeById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');
    final response = await HttpErrorHandler.executeRequest(() => httpClient.delete(uri, headers: headers));

    HttpErrorHandler.handleResponse(response, 'Failed to delete room type');
  }
}
