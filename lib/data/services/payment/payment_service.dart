import 'dart:convert';

import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
// Create a DTO for payment data
class PaymentRequestDto {
  final int roomId;
  final bool penalty;
  final bool lastPayment;
  final List<Map<String, dynamic>> consumptions;

  PaymentRequestDto({
    required this.roomId,
    required this.penalty,
    required this.lastPayment,
    required this.consumptions,
  });

  Map<String, dynamic> toJson() => {
    "room_id": roomId,
    "penalty": penalty,
    "lastPayment": lastPayment,
    "consumptions": consumptions,
  };
}

// Then update your service to accept the DTO
abstract class PaymentService {
  Future<Map<String, dynamic>> processPayment(PaymentRequestDto request);
}

class ApiPaymentService extends ApiBase implements PaymentService {
  @override
  Future<Map<String, dynamic>> processPayment(PaymentRequestDto request) async {
    final uri = buildUri(Endpoints.proceedPayment);
    final headers = await buildHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      ),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to process payment',
    ) as Map<String, dynamic>;

    return decoded;
  }
}