// Example of how home_service.dart will look when connected to real API
// Copy and paste these implementations when your backend is ready

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/data/dto/dashboard_summary_dto.dart';
import 'package:app/data/dto/invoice_dto.dart';
import 'package:app/data/dto/notification_dto.dart';

class HomeService {
  final AuthService _authService;

  HomeService(this._authService);

  /// Fetch dashboard summary data
  Future<DashboardSummary> fetchDashboardSummary() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri(Endpoints.dashboardSummary);
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      dev.log('[HTTP] GET $uri -> ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // Use DTO to parse JSON and convert to domain model
        return DashboardSummaryDto.fromJson(json).toDomain();
      }

      throw Exception('Failed to fetch dashboard summary: ${response.statusCode}');
    } catch (e) {
      dev.log('Error fetching dashboard summary: $e');
      rethrow;
    }
  }

  /// Fetch recent invoices/receipts
  Future<List<Invoice>> fetchRecentInvoices({int limit = 5}) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri('${Endpoints.recentInvoices}?limit=$limit');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      dev.log('[HTTP] GET $uri -> ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = json['data'] ?? json['invoices'] ?? [];
        // Use DTO to parse JSON and convert to domain models
        return data
            .map((item) => InvoiceDto.fromJson(item as Map<String, dynamic>).toDomain())
            .toList();
      }

      throw Exception('Failed to fetch recent invoices: ${response.statusCode}');
    } catch (e) {
      dev.log('Error fetching recent invoices: $e');
      rethrow;
    }
  }

  /// Send payment reminders for delayed invoices
  Future<void> sendPaymentReminders({List<int>? invoiceIds}) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri(Endpoints.sendReminders);
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (invoiceIds != null) 'invoice_ids': invoiceIds,
        }),
      ).timeout(const Duration(seconds: 20));

      dev.log('[HTTP] POST $uri -> ${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to send reminders: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Error sending reminders: $e');
      rethrow;
    }
  }

  /// Fetch notifications for the user
  Future<List<AppNotification>> fetchNotifications({bool unreadOnly = false}) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri('${Endpoints.notifications}${unreadOnly ? '?unread=true' : ''}');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      dev.log('[HTTP] GET $uri -> ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = json['data'] ?? json['notifications'] ?? [];
        // Use DTO to parse JSON and convert to domain models
        return data
            .map((item) => NotificationDto.fromJson(item as Map<String, dynamic>).toDomain())
            .toList();
      }

      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    } catch (e) {
      dev.log('Error fetching notifications: $e');
      rethrow;
    }
  }
}
