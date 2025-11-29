import 'dart:async';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:http/http.dart' as http;


class ApiBase {
  final AuthService auth = AuthService();
  final http.Client httpClient = http.Client();

  Uri buildUri(String path) => Endpoints.uri(path);

  Future<Map<String, String>> buildHeaders() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    final token = await auth.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

}
