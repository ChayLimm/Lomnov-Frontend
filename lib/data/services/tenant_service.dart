import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/dto/paginated_result.dart';

class TenantDto {
  final int id;
  final int landlordId;
  final String firstName;
  final String lastName;

  TenantDto({
    required this.id,
    required this.landlordId,
    required this.firstName,
    required this.lastName,
  });

  factory TenantDto.fromJson(Map<String, dynamic> json) {
    return TenantDto(
      id: json['id'],
      landlordId: json['landlord_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }
}

class TenantService {
  Future<PaginatedResult<TenantDto>> fetchTenants(int landlordId, {int page = 1, int perPage = 15}) async {
    final path = '${Endpoints.tenantsByLandlord(landlordId)}?page=$page&per_page=$perPage';
    final url = Endpoints.uri(path);
    dev.log('[HTTP] GET $url');
    final headers = {
      'Accept': 'application/json',
      // ngrok shows an interstitial HTML page for browser-like requests; this header
      // tells ngrok to skip the browser warning and return the raw response.
      'ngrok-skip-browser-warning': 'true',
    };
    dev.log('[HTTP] Request headers: $headers');
    final response = await http.get(url, headers: headers);
    dev.log('[HTTP] <- ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = (data['data'] is List) ? (data['data'] as List) : <dynamic>[];
      final items = list.map((e) => TenantDto.fromJson(e as Map<String, dynamic>)).toList();
      final paginationJson = data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{
        'current_page': page,
        'per_page': perPage,
        'total': items.length,
        'last_page': 1,
        'from': items.isNotEmpty ? 1 : null,
        'to': items.isNotEmpty ? items.length : null,
      };
      final pagination = Pagination.fromJson(paginationJson);
      return PaginatedResult<TenantDto>(items: items, pagination: pagination);
    }
    throw Exception('Failed to fetch tenants');
  }
}
