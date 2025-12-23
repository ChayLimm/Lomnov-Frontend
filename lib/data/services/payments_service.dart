import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/dto/paginated_result.dart';
import '../../domain/models/payment.dart';

class PaymentsService {
  PaymentsService();

  // Simple in-memory cache to avoid duplicate network calls during a single
  // app session. Keyed by landlordId; value is the list of payments fetched
  // (usually fetched with a large perPage like 1000 by the dashboard).
  static final Map<int, List<Payment>> _cachedPaymentsByLandlord = {};

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
    // If we have a cached full payment list for this landlord, use it to
    // satisfy requests locally (avoids extra network traffic). We only cache
    // the raw items; pagination and simple status filtering are applied here.
    final cached = _cachedPaymentsByLandlord[landlordId];
    if (cached != null && cached.isNotEmpty) {
      List<Payment> filtered = cached;
      if (status != null && status.isNotEmpty) {
        final wanted = status.split(',').map((s) => s.trim().toLowerCase()).toList();
        filtered = cached.where((p) {
          final s = (p.status ?? '').toLowerCase();
          return wanted.any((w) => s.contains(w) || s == w);
        }).toList();
      }
      final total = filtered.length;
      final lastPage = (total / perPage).ceil().clamp(1, 999999);
      final from = total == 0 ? null : ((page - 1) * perPage) + 1;
      final to = total == 0 ? null : (page * perPage).clamp(1, total);
      final pageItems = filtered.skip((page - 1) * perPage).take(perPage).toList();
      final pagination = Pagination.fromJson({
        'current_page': page,
        'per_page': perPage,
        'total': total,
        'last_page': lastPage,
        'from': from,
        'to': to,
      });
      return PaginatedResult<Payment>(items: pageItems, pagination: pagination);
    }

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
    // Cache the results when we receive a large first-page result (dashboard
    // tends to request page=1&per_page=1000). This lets other widgets reuse
    // the already-fetched payments without hitting the network again.
    if ((page == 1 && perPage >= 1000) || (status == null || status.isEmpty)) {
      try {
        _cachedPaymentsByLandlord[landlordId] = items;
      } catch (_) {
        // ignore cache write failures
      }
    }
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
