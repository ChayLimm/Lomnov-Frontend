import 'dart:convert';
import 'dart:developer' as dev;
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/room_dto.dart';

/// Simple pagination metadata container
class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      perPage: json['per_page'] ?? json['perPage'] ?? 15,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? json['lastPage'] ?? 1,
    );
  }
}

/// Result wrapper for paginated rooms
class RoomsResponse {
  final List<RoomDto> items;
  final Pagination pagination;

  RoomsResponse({required this.items, required this.pagination});
}

class RoomFetchService extends ApiBase {
  /// Fetch rooms from the API. Supports pagination via [page] and [perPage].
  /// If [buildingId] is provided it will be added as a query parameter.
  Future<RoomsResponse> fetchRooms({int page = 1, int perPage = 15, int? buildingId}) async {
    // Build URI and query parameters
    var uri = buildUri('/api/rooms');
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (buildingId != null) query['buildingId'] = buildingId.toString();
    uri = uri.replace(queryParameters: query);

    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to load rooms',
    );

    List<dynamic> list = const [];
    Pagination pagination = Pagination(currentPage: page, perPage: perPage, total: 0, lastPage: page);

    if (decoded is Map<String, dynamic>) {
      // data array
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['rooms'] is List) {
        list = decoded['rooms'] as List;
      }

      if (decoded['pagination'] is Map<String, dynamic>) {
        pagination = Pagination.fromJson(decoded['pagination'] as Map<String, dynamic>);
      }
    } else if (decoded is List) {
      list = decoded;
      pagination = Pagination(currentPage: page, perPage: perPage, total: list.length, lastPage: page);
    }

    final items = RoomDto.fromJsonList(list);
    return RoomsResponse(items: items, pagination: pagination);
  }

  /// Delete a room by id using DELETE /api/rooms/{id}
  /// Throws on failure via HttpErrorHandler
  Future<void> deleteRoom(int roomId) async {
    final uri = buildUri('/api/rooms/$roomId');
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
    );

    // Will throw if status is not successful
    HttpErrorHandler.handleResponse(response, 'Failed to delete room');
  }

  /// Create a room using POST /api/rooms
  /// Expects a JSON serializable [payload] containing required fields.
  /// Returns the created RoomDto on success.
  Future<RoomDto> createRoom(Map<String, dynamic> payload) async {
    final uri = buildUri('/api/rooms');
    final headers = await buildHeaders();

    dev.log('[HTTP] POST $uri payload=${payload.toString()}');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to create room');

    if (decoded is Map<String, dynamic>) {
      // try to find created object in data or return the map itself
      final data = decoded['data'] ?? decoded['room'] ?? decoded;
      if (data is Map<String, dynamic>) return RoomDto.fromJson(data);
    }

    // fallback: if response is a list or unknown, throw
    throw Exception('Unexpected response when creating room');
  }

  /// Update a room using PUT /api/rooms/{id}
  /// Returns updated RoomDto on success.
  Future<RoomDto> updateRoom(int roomId, Map<String, dynamic> payload) async {
    final uri = buildUri('/api/rooms/$roomId');
    final headers = await buildHeaders();

    dev.log('[HTTP] PUT $uri payload=${payload.toString()}');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.put(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to update room');
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['room'] ?? decoded;
      if (data is Map<String, dynamic>) return RoomDto.fromJson(data);
    }

    throw Exception('Unexpected response when updating room');
  }
}
