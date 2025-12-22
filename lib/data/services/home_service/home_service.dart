import 'dart:async';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_status.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/data/mock_data/mock_data.dart';
import 'package:app/data/services/payments_service.dart';
import 'package:app/data/services/reports_service.dart';
import 'package:app/domain/models/payment.dart';

class HomeService {

  final AuthService _authService;

  HomeService(this._authService);

  /// Fetch dashboard summary data

  Future<DashboardSummary> fetchDashboardSummary() async {
    // Try to fetch a richer dashboard summary using the reports endpoint.
    try {
      final int? landlordId = await _authService.getLandlordId();
      final lid = landlordId ?? 1;

      // Fetch receipts/payments and compute counts/totals from them across all pages
      final paymentsPaged = await PaymentsService().fetchLandlordPayments(lid, page: 1, perPage: 1000);

      final int total = paymentsPaged.pagination.total;
      final int lastPage = paymentsPaged.pagination.lastPage;
      final int perPage = paymentsPaged.pagination.perPage;

      double totalIncomeFromPayments = 0.0;
      final Map<InvoiceStatus, int> counts = {
        InvoiceStatus.paid: 0,
        InvoiceStatus.unpaid: 0,
        InvoiceStatus.pending: 0,
        InvoiceStatus.delay: 0,
      };

      int paidCount = 0;

      // helper to process a page of payments
      void processPayments(List<Payment> payments) {
        for (final Payment p in payments) {
          // Strict status-based classification: only use the status string
          // reported by the payments endpoint. This avoids inferring paid
          // from transaction ids or receipts.
          final st = (p.status ?? '').toLowerCase();

          // debug print each payment's key fields
          // ignore: avoid_print
          print('[Dashboard][Payment] id=${p.id} status=$st transaction=${p.transactionId} receipt=${p.receiptUrl} roomStatus=${p.roomStatus}');

          if (st.contains('paid')) {
            paidCount += 1;
            counts[InvoiceStatus.paid] = (counts[InvoiceStatus.paid] ?? 0) + 1;
          } else if (st.contains('pending')) {
            counts[InvoiceStatus.pending] = (counts[InvoiceStatus.pending] ?? 0) + 1;
          } else if (st.contains('delay') || st.contains('delayed') || st.contains('overdue')) {
            counts[InvoiceStatus.delay] = (counts[InvoiceStatus.delay] ?? 0) + 1;
          } else if (st.contains('unpaid')) {
            counts[InvoiceStatus.unpaid] = (counts[InvoiceStatus.unpaid] ?? 0) + 1;
          } else {
            // Any unknown/other values treated as unpaid
            counts[InvoiceStatus.unpaid] = (counts[InvoiceStatus.unpaid] ?? 0) + 1;
          }

          for (final it in p.items) {
            totalIncomeFromPayments += double.tryParse(it.subtotal) ?? 0.0;
          }
        }
      }

      // process first page
      processPayments(paymentsPaged.items);

      // fetch and process remaining pages if any
      if (lastPage > 1) {
        for (int page = 2; page <= lastPage; page++) {
          try {
            final next = await PaymentsService().fetchLandlordPayments(lid, page: page, perPage: perPage);
            processPayments(next.items);
          } catch (_) {
            // ignore page errors but continue with what we have
          }
        }
      }
      // Prefer totalIncome from the reports endpoint when available.
      double finalTotalIncome = totalIncomeFromPayments;
      try {
        final reports = ApiReportsService();
        final now = DateTime.now();
        final period = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final report = await reports.fetchReport(period: period, landlordId: lid);
        finalTotalIncome = report.totalIncome;
      } catch (_) {
        // ignore and keep sum from payments
      }

      final now = DateTime.now();
      // Debug: print computed counts so it's easy to track issues during dev
      // ignore: avoid_print
      print('[Dashboard] total=$total paid=$paidCount income=$finalTotalIncome');
      return DashboardSummary(
        userName: 'You',
        avatarUrl: null,
        totalInvoices: total,
        paidInvoices: paidCount,
        totalIncome: finalTotalIncome,
        month: DateTime(now.year, now.month, 1),
        counts: counts,
      );
    } catch (e) {
      // Fallback to existing mock data to keep UI functional.
      return fetchDashboardMock();
    }

    // Future API implementation:
    /*
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

    final uri = Endpoints.uri(Endpoints.recentInvoices + '?limit=$limit');
    
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
    final token = await _auth_service.getToken();
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
    */
  }

  /// Fetch notifications for the user
  
  Future<List<AppNotification>> fetchNotifications({bool unreadOnly = false}) async {
    // For now, return mock data
    return fetchNotificationsMock(unreadOnly: unreadOnly);

    // Future API implementation:
    /*
    final token = await _auth_service.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Endpoints.uri(Endpoints.notifications + (unreadOnly ? '?unread=true' : ''));
    
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
