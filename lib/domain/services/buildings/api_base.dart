import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:app/domain/services/auth_service.dart';

/// Internal base class providing common HTTP utilities (base URL, headers).
class ApiBase {
  ApiBase() {
    _baseUrl = _normalizeBaseUrl(dotenv.env['BASE_URL'] ?? '');
  }

  late final String _baseUrl;
  final AuthService auth = AuthService();
  final http.Client httpClient = http.Client();

  Uri buildUri(String path) => Uri.parse('$_baseUrl$path');

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

  String _normalizeBaseUrl(String input) {
    var url = input.trim();
    if (url.isEmpty) {
      throw Exception('BASE_URL is not set. Add BASE_URL to your .env');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    dev.log('[ApiBase] baseUrl=$url');
    return url;
  }
}
