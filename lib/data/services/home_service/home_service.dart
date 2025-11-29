import 'dart:async';
// import 'dart:convert';
// import 'dart:developer' as dev;
// import 'package:http/http.dart' as http;
// import 'package:app/data/services/endpoints.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/data/mock_data/mock_data.dart';

/// Service for fetching home/dashboard data from the API.
/// Currently uses mock data but structured for easy API integration.
class HomeService {
  // ignore: unused_field
  final AuthService _authService;

  HomeService(this._authService);

  /// Fetch dashboard summary data

  Future<DashboardSummary> fetchDashboardSummary() async {
    // For now, return mock data
    return fetchDashboardMock();

    // Future API implementation:
    /*
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri('/api/dashboard/summary');
    
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
        return DashboardSummary.fromJson(json);
      }

      throw Exception('Failed to fetch dashboard summary: ${response.statusCode}');
    } catch (e) {
      dev.log('Error fetching dashboard summary: $e');
      rethrow;
    }
    */
  }

  /// Fetch recent invoices/receipts
  
  Future<List<Invoice>> fetchRecentInvoices({int limit = 5}) async {
    // For now, return mock data
    return fetchRecentInvoicesMock(limit: limit);

    // Future API implementation:
    /*
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri('/api/invoices/recent?limit=$limit');
    
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
        return data.map((item) => Invoice.fromJson(item)).toList();
      }

      throw Exception('Failed to fetch recent invoices: ${response.statusCode}');
    } catch (e) {
      dev.log('Error fetching recent invoices: $e');
      rethrow;
    }
    */
  }

  /// Send payment reminders for delayed invoices
  
  Future<void> sendPaymentReminders({List<int>? invoiceIds}) async {
    // Mock delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Future API implementation:
    /*
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri('/api/invoices/send-reminders');
    
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
    */
  }

  /// Fetch notifications for the user
  
  Future<List<AppNotification>> fetchNotifications({bool unreadOnly = false}) async {
    // For now, return mock data
    return fetchNotificationsMock(unreadOnly: unreadOnly);

    // Future API implementation:
    /*
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri('/api/notifications${unreadOnly ? '?unread=true' : ''}');
    
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
        return data.map((item) => Notification.fromJson(item)).toList();
      }

      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    } catch (e) {
      dev.log('Error fetching notifications: $e');
      rethrow;
    }
    */
  }
}
