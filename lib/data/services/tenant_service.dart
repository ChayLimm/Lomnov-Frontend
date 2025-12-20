import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:app/data/endpoint/endpoints.dart';

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
  Future<List<TenantDto>> fetchTenants(int landlordId) async {
    final url = Endpoints.uri(Endpoints.tenantsByLandlord(landlordId));
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
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => TenantDto.fromJson(e))
            .toList();
      }
    }
    throw Exception('Failed to fetch tenants');
  }
}
