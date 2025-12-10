import 'dart:developer' as dev;
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/contract_dto.dart';

/// Service for managing room contract API calls
class ContractService extends ApiBase {
  /// GET /api/rooms/{roomId}/activeContract - Get active contract for a room
  Future<ContractDto?> fetchActiveContract(int roomId) async {
    final uri = buildUri(Endpoints.roomActiveContract(roomId));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to load active contract',
    );

    // Handle case where no contract exists
    if (decoded == null || decoded is! Map<String, dynamic>) {
      return null;
    }

    // Check if there's a contract field in response
    if (decoded['contract'] != null) {
      return ContractDto.fromJson(decoded['contract'] as Map<String, dynamic>);
    }

    return null;
  }
}
