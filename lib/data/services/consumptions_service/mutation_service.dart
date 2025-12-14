import 'dart:developer' as dev;
import 'package:app/data/dto/consumption_dto.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/services/buildings_service/api_base.dart';

class ConsumptionsMutationService extends ApiBase {
  Future<ConsumptionDto> create({
    required int roomId,
    required int serviceId,
    required double endReading,
    String? photoUrl,
    double? consumption,
  }) async {
    final uri = buildUri(Endpoints.consumptions);
    final headers = await buildHeaders();
    final body = {
      'room_id': roomId,
      'service_id': serviceId,
      'end_reading': endReading,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (consumption != null) 'consumption': consumption,
    };

    dev.log('[HTTP] POST $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: body),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to create consumption',
    );

    if (decoded is Map<String, dynamic>) {
      final map = decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded;
      return ConsumptionDto.fromJson(map);
    }

    throw Exception('Unexpected response format');
  }

  Future<ConsumptionDto> update({
    required int id,
    int? roomId,
    int? serviceId,
    double? endReading,
    String? photoUrl,
    double? consumption,
  }) async {
    final uri = buildUri(Endpoints.consumptionById(id));
    final headers = await buildHeaders();
    final body = <String, dynamic>{
      if (roomId != null) 'room_id': roomId,
      if (serviceId != null) 'service_id': serviceId,
      if (endReading != null) 'end_reading': endReading,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (consumption != null) 'consumption': consumption,
      '_method': 'PATCH',
    };

    dev.log('[HTTP] PATCH $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: body),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to update consumption',
    );

    if (decoded is Map<String, dynamic>) {
      final map = decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded;
      return ConsumptionDto.fromJson(map);
    }

    throw Exception('Unexpected response format');
  }

  Future<void> delete(int id) async {
    final uri = buildUri(Endpoints.consumptionById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
    );

    HttpErrorHandler.handleDeleteResponse(
      response,
      'Failed to delete consumption',
    );
  }
}
