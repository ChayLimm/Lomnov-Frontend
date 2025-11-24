import 'dart:developer' as dev;
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/building_dto.dart';

class BuildingFetchService extends ApiBase {
  Future<List<BuildingDto>> fetchBuildings() async {
  final uri = buildUri(Endpoints.buildings);
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load buildings',
    );

    // Extract list from various response formats
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

    return BuildingDto.fromJsonList(list);
  }

  /// Fetch buildings for a specific landlord.
  ///
  /// If [landlordId] is not provided, this will attempt to read the
  /// persisted landlord id from the `AuthService` (the id stored at
  /// login). Throws if no landlord id is available.
  Future<List<BuildingDto>> fetchBuildingsForLandlord({
    int? landlordId,
  }) async {
    landlordId ??= await auth.getLandlordId();
    if (landlordId == null) {
      throw Exception('No landlordId available. Ensure user is signed in.');
    }

  final uri = buildUri(Endpoints.buildingsByLandlord(landlordId));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load buildings for landlord $landlordId',
    );

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

    return BuildingDto.fromJsonList(list);
  }

  Future<BuildingDto> fetchBuildingById(int id) async {
  final uri = buildUri(Endpoints.buildingById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to load building',
    );

    // Extract model from various response formats
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return BuildingDto.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return BuildingDto.fromJson(decoded);
    }

    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return BuildingDto.fromJson(decoded.first as Map<String, dynamic>);
    }

    throw Exception('Unexpected response format');
  }
}
