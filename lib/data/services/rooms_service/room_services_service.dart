import 'dart:convert';
import 'dart:developer' as dev;
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/service_dto.dart';

/// Service for managing room services (facilities) API calls
class RoomServicesService extends ApiBase {
  /// GET /api/rooms/{roomId}/services - Get all services for a room
  Future<List<ServiceDto>> fetchRoomServices(int roomId) async {
    final uri = buildUri(Endpoints.roomServices(roomId));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri headers=${headers.keys.join(',')}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
      timeout: const Duration(seconds: 5),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load room services',
    );

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['services'] is List) {
        list = decoded['services'] as List;
      }
    }
    list ??= const [];

    return list.map((json) => ServiceDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// POST /api/rooms/{roomId}/services - Attach a service to room
  Future<ServiceDto> attachService(int roomId, int serviceId) async {
    final uri = buildUri(Endpoints.roomServices(roomId));
    final headers = await buildHeaders();
    final payload = {'service_id': serviceId};

    dev.log('[HTTP] POST $uri headers=${headers.keys.join(',')} payload=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
      timeout: const Duration(seconds: 10),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to attach service',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return ServiceDto.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return ServiceDto.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  /// DELETE /api/rooms/{roomId}/services/{serviceId} - Remove service from room
  Future<void> detachService(int roomId, int serviceId) async {
    final uri = buildUri(Endpoints.roomServiceById(roomId, serviceId));
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri headers=${headers.keys.join(',')}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
      timeout: const Duration(seconds: 10),
    );

    HttpErrorHandler.handleResponse(response, 'Failed to detach service');
  }
}
