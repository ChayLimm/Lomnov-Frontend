import 'package:flutter/material.dart';
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/domain/repositories/home_repository.dart';

/// ViewModel for the Home/Dashboard view.
/// Manages state and business logic for the home screen.
class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  HomeViewModel(this._repository);

  // State
  DashboardSummary? _dashboardSummary;
  List<Invoice>? _recentInvoices;
  List<AppNotification>? _notifications;
  
  bool _isLoadingDashboard = false;
  bool _isLoadingInvoices = false;
  bool _isLoadingNotifications = false;
  bool _isSendingReminders = false;
  
  String? _error;
  int _unreadNotificationCount = 0;

  // Getters
  DashboardSummary? get dashboardSummary => _dashboardSummary;
  List<Invoice>? get recentInvoices => _recentInvoices;
  List<AppNotification>? get notifications => _notifications;
  
  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingInvoices => _isLoadingInvoices;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool get isSendingReminders => _isSendingReminders;
  bool get isLoading => _isLoadingDashboard || _isLoadingInvoices || _isLoadingNotifications;
  
  String? get error => _error;
  int get unreadNotificationCount => _unreadNotificationCount;

  /// Load dashboard summary data
  Future<void> loadDashboardSummary() async {
    _isLoadingDashboard = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardSummary = await _repository.getDashboardSummary();
      _error = null;
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
      debugPrint(_error);
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  /// Load recent invoices
  Future<void> loadRecentInvoices({int limit = 5}) async {
    _isLoadingInvoices = true;
    notifyListeners();

    try {
      _recentInvoices = await _repository.getRecentInvoices(limit: limit);
    } catch (e) {
      _error = 'Failed to load invoices: $e';
      debugPrint(_error);
    } finally {
      _isLoadingInvoices = false;
      notifyListeners();
    }
  }

  /// Load notifications
  Future<void> loadNotifications({bool unreadOnly = false}) async {
    _isLoadingNotifications = true;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(unreadOnly: unreadOnly);
      _unreadNotificationCount = _notifications?.where((n) => !n.isRead).length ?? 0;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      debugPrint(_error);
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  /// Send payment reminders
  Future<bool> sendPaymentReminders({List<int>? invoiceIds}) async {
    _isSendingReminders = true;
    notifyListeners();

    try {
      await _repository.sendPaymentReminders(invoiceIds: invoiceIds);
      _isSendingReminders = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send reminders: $e';
      debugPrint(_error);
      _isSendingReminders = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboardSummary(),
      loadRecentInvoices(),
      loadNotifications(),
    ]);
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
