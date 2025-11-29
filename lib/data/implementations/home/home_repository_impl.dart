import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/data/services/home_service/home_service.dart';
import 'package:app/domain/repositories/home_repository.dart';

/// Implementation of HomeRepository that uses HomeService.
/// Currently uses mock data, but ready for API integration.
class HomeRepositoryImpl implements HomeRepository {
  final HomeService _homeService;

  HomeRepositoryImpl(this._homeService);

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      return await _homeService.fetchDashboardSummary();
    } catch (e) {
      // Add error handling/logging as needed
      rethrow;
    }
  }

  @override
  Future<List<Invoice>> getRecentInvoices({int limit = 5}) async {
    try {
      return await _homeService.fetchRecentInvoices(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendPaymentReminders({List<int>? invoiceIds}) async {
    try {
      return await _homeService.sendPaymentReminders(invoiceIds: invoiceIds);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AppNotification>> getNotifications({bool unreadOnly = false}) async {
    try {
      return await _homeService.fetchNotifications(unreadOnly: unreadOnly);
    } catch (e) {
      rethrow;
    }
  }
}
