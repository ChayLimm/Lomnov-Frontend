import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/notification_model.dart';

/// Repository interface for home/dashboard data.
/// This abstraction allows easy swapping between mock data and real API calls.
abstract class HomeRepository {
  /// Fetch dashboard summary data
  Future<DashboardSummary> getDashboardSummary();

  /// Fetch recent invoices
  Future<List<Invoice>> getRecentInvoices({int limit = 5});

  /// Send payment reminders for delayed invoices
  Future<void> sendPaymentReminders({List<int>? invoiceIds});

  /// Fetch notifications
  Future<List<AppNotification>> getNotifications({bool unreadOnly = false});
}
