import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/dto/paginated_result.dart';
import '../../domain/models/payment.dart';

class PaymentsService {
  PaymentsService();

  Future<PaginatedResult<Payment>> fetchLandlordPayments(int landlordId, {int page = 1, int perPage = 5, String? status, String? sortBy, String? sortDir}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status.toLowerCase();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
    if (sortDir != null && sortDir.isNotEmpty) queryParams['sort_dir'] = sortDir;

    final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    final path = '${Endpoints.paymentsByLandlord(landlordId)}?$queryString';
    final uri = Endpoints.uri(path);
    final headers = {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    dev.log('[HTTP] GET $uri');
    dev.log('[HTTP] Request headers: $headers');
    final res = await http.get(uri, headers: headers);
    dev.log('[HTTP] <- ${res.statusCode} ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('Failed to load payments: ${res.statusCode} - ${res.body}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? <dynamic>[];
    final items = data.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
    final paginationJson = body['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{
      'current_page': page,
      'per_page': perPage,
      'total': items.length,
      'last_page': 1,
      'from': items.isNotEmpty ? 1 : null,
      'to': items.isNotEmpty ? items.length : null,
    };
    final pagination = Pagination.fromJson(paginationJson);
    return PaginatedResult<Payment>(items: items, pagination: pagination);
  }
}
