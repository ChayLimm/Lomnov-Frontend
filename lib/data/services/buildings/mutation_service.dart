import 'dart:convert';
import 'dart:developer' as dev;
import 'package:app/domain/models/building_model.dart';
import 'package:app/domain/services/buildings/api_base.dart';
import 'package:app/domain/services/http_error_handler.dart';

class BuildingMutationService extends ApiBase {
  Future<void> deleteBuilding(int id) async {
    final uri = buildUri('/api/buildings/$id');
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');
    
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
    );

    HttpErrorHandler.handleDeleteResponse(
      response,
      'Failed to delete building',
    );
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
    
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.put(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to update building',
    );

    // Extract model from various response formats
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
    
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to create building',
    );

    // Extract model from various response formats
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
}
