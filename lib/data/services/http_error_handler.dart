import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service for handling HTTP request errors and response parsing.
/// Centralizes error handling logic to avoid code duplication.
class HttpErrorHandler {
  /// Executes an HTTP request with standardized error handling.
  /// 
  /// Catches common network errors (timeout, socket, http, format exceptions)
  /// and wraps them in user-friendly error messages.
  static Future<http.Response> executeRequest(
    Future<http.Response> Function() request, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw Exception('Request timeout – please try again');
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error communicating with server');
    } on FormatException {
      throw Exception('Bad response format from server');
    }
  }

  /// Logs the HTTP response for debugging purposes.
  static void logResponse(http.Response response) {
    final status = response.statusCode;
    final bodyStr = response.body.trim();
    dev.log('[HTTP] <- $status ${bodyStr.isEmpty ? '<empty body>' : bodyStr}');
  }

  /// Decodes JSON response body with error handling.
  /// 
  /// Returns decoded JSON or throws an exception if parsing fails.
  static dynamic decodeJsonResponse(http.Response response) {
    final bodyStr = response.body.trim();
    
    if (bodyStr.isEmpty) {
      return <String, dynamic>{};
    }

    final contentType = response.headers['content-type'] ?? '';
    final looksLikeJson = contentType.contains('application/json') ||
        bodyStr.startsWith('{') ||
        bodyStr.startsWith('[');

    if (looksLikeJson) {
      try {
        return jsonDecode(bodyStr);
      } catch (e) {
        dev.log('JSON decode failed: $e');
        throw Exception('Failed to parse response');
      }
    }

    throw Exception('Unexpected non-JSON response from server');
  }

  /// Decodes JSON response specifically for list responses.
  static dynamic decodeJsonListResponse(http.Response response) {
    final bodyStr = response.body.trim();
    
    if (bodyStr.isEmpty) {
      return [];
    }

    return decodeJsonResponse(response);
  }

  /// Extracts error message from response body.
  /// 
  /// Attempts to extract error message from various common response formats.
  /// Falls back to provided [fallbackMessage] if extraction fails.
  static String extractErrorMessage(
    dynamic decoded,
    String fallbackMessage,
  ) {
    if (decoded is Map<String, dynamic>) {
      // Try 'message' field
      if (decoded['message'] is String) {
        return decoded['message'];
      }
      
      // Try 'error' field
      if (decoded['error'] is String) {
        return decoded['error'];
      }
      
      // Try 'errors' object (validation errors)
      if (decoded['errors'] is Map<String, dynamic>) {
        final errors = (decoded['errors'] as Map<String, dynamic>)
            .values
            .expand((v) => v is List ? v : [v])
            .join('\n');
        if (errors.isNotEmpty) return errors;
      }
      
      // Try 'raw' field (from our own error responses)
      if (decoded['raw'] is String && decoded['raw'].toString().isNotEmpty) {
        return decoded['raw'];
      }
    }
    
    return fallbackMessage;
  }

  /// Checks if the HTTP status code indicates success.
  static bool isSuccessStatus(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Checks if the HTTP status code indicates no content.
  static bool isNoContentStatus(int statusCode) {
    return statusCode == 204;
  }

  /// Handles a response and throws an exception if it's an error.
  /// 
  /// For successful responses, returns the decoded body.
  /// For error responses, extracts and throws an appropriate error message.
  static dynamic handleResponse(
    http.Response response,
    String fallbackError,
  ) {
    logResponse(response);
    final decoded = decodeJsonResponse(response);
    final status = response.statusCode;

    if (isSuccessStatus(status)) {
      return decoded;
    }

    final message = extractErrorMessage(decoded, fallbackError);
    throw Exception(message);
  }

  /// Handles a list response and throws an exception if it's an error.
  static dynamic handleListResponse(
    http.Response response,
    String fallbackError,
  ) {
    logResponse(response);
    final decoded = decodeJsonListResponse(response);
    final status = response.statusCode;

    if (isSuccessStatus(status)) {
      return decoded;
    }

    final message = extractErrorMessage(decoded, fallbackError);
    throw Exception(message);
  }

  /// Handles a DELETE response (which may return 204 No Content).
  static void handleDeleteResponse(
    http.Response response,
    String fallbackError,
  ) {
    final status = response.statusCode;
    final bodyStr = response.body.trim();
    dev.log('[HTTP] <- $status ${bodyStr.isEmpty ? '<empty body>' : bodyStr}');

    if (isNoContentStatus(status) || isSuccessStatus(status)) {
      return;
    }

    // Try to decode error message
    dynamic decoded;
    try {
      if (bodyStr.isNotEmpty) {
        decoded = decodeJsonResponse(response);
      }
    } catch (_) {
      // If decoding fails, just use the fallback
    }

    final message = extractErrorMessage(decoded, fallbackError);
    throw Exception(message);
  }
}
