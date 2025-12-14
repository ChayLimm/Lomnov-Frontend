import 'dart:developer' as dev;
import 'package:app/data/dto/consumption_dto.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/services/buildings_service/api_base.dart';

class ConsumptionsFetchService extends ApiBase {
  Future<List<ConsumptionDto>> fetchByRoom(int roomId) async {
    final uri = buildUri(Endpoints.consumptionsByRoom(roomId));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load consumptions for room $roomId',
    );

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['consumptions'] is List) {
        list = decoded['consumptions'] as List;
      }
    }
    list ??= const [];

    return ConsumptionDto.fromJsonList(list);
  }
}
