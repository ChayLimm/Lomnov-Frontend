import 'dart:async';
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/invoice_status.dart';
import 'package:app/domain/models/home_model/notification_model.dart';

// ============================================================================
// MOCK DATA - Replace with real API calls later
// ============================================================================

/// Mock dashboard data
final DashboardSummary kMockDashboard = DashboardSummary(
  userName: 'mock_user',
  avatarUrl:
      'https://www.svg.com/img/gallery/why-princess-zelda-sounds-so-familiar-in-tears-of-the-kingdom/intro-1683545985.jpg',
  totalInvoices: 40,
  paidInvoices: 30,
  totalIncome: 2262.50,
  month: DateTime(2025, 10, 1),
  counts: {
    InvoiceStatus.unpaid: 4,
    InvoiceStatus.pending: 4,
    InvoiceStatus.paid: 30,
    InvoiceStatus.delay: 1,
  },
);

/// Mock invoices data
final List<Invoice> kMockInvoices = [
  Invoice(
    id: 1,
    tenantName: 'John Doe',
    roomNumber: 'A101',
    amount: 500.00,
    status: InvoiceStatus.paid,
    dueDate: DateTime(2025, 10, 1),
    paidDate: DateTime(2025, 9, 28),
  ),
  Invoice(
    id: 2,
    tenantName: 'Jane Smith',
    roomNumber: 'B205',
    amount: 450.00,
    status: InvoiceStatus.pending,
    dueDate: DateTime(2025, 10, 15),
  ),
  Invoice(
    id: 3,
    tenantName: 'Mike Johnson',
    roomNumber: 'C303',
    amount: 600.00,
    status: InvoiceStatus.unpaid,
    dueDate: DateTime(2025, 10, 5),
  ),
  Invoice(
    id: 4,
    tenantName: 'Sarah Williams',
    roomNumber: 'D401',
    amount: 550.00,
    status: InvoiceStatus.delay,
    dueDate: DateTime(2025, 9, 20),
  ),
  Invoice(
    id: 5,
    tenantName: 'Tom Brown',
    roomNumber: 'A102',
    amount: 500.00,
    status: InvoiceStatus.paid,
    dueDate: DateTime(2025, 10, 1),
    paidDate: DateTime(2025, 9, 30),
  ),
];

/// Mock notifications data
final List<AppNotification> kMockNotifications = [
  AppNotification(
    id: 1,
    title: 'Payment Received',
    message: 'John Doe has paid rent for Room A101',
    createdAt: DateTime(2025, 10, 28),
    isRead: false,
    type: 'payment',
  ),
  AppNotification(
    id: 2,
    title: 'Payment Overdue',
    message: 'Sarah Williams payment is 10 days overdue',
    createdAt: DateTime(2025, 10, 25),
    isRead: false,
    type: 'warning',
  ),
  AppNotification(
    id: 3,
    title: 'New Tenant',
    message: 'New tenant registered for Room E501',
    createdAt: DateTime(2025, 10, 20),
    isRead: true,
    type: 'info',
  ),
];

// ============================================================================
// MOCK API FUNCTIONS
// ============================================================================

/// Simulates fetching dashboard data from a backend service.

Future<DashboardSummary> fetchDashboardMock() async {
  await Future.delayed(const Duration(milliseconds: 450));
  return kMockDashboard;
}

/// Simulates fetching recent invoices from a backend service.

Future<List<Invoice>> fetchRecentInvoicesMock({int limit = 5}) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return kMockInvoices.take(limit).toList();
}

/// Simulates fetching notifications from a backend service.

Future<List<AppNotification>> fetchNotificationsMock({bool unreadOnly = false}) async {
  await Future.delayed(const Duration(milliseconds: 250));
  if (unreadOnly) {
    return kMockNotifications.where((n) => !n.isRead).toList();
  }
  return kMockNotifications;
}
