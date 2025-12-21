import 'package:flutter/foundation.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/data/dto/notification_dto.dart';
import 'package:app/data/services/notifications/notification_service.dart';
import 'package:app/data/services/auth_service/auth_service.dart';

enum NotificationTab { payment, registration }

class NotificationState extends ChangeNotifier {
  NotificationState({NotificationService? service})
      : _service = service ?? NotificationService();

  final NotificationService _service;

  bool _loading = false;
  String? _error;
  NotificationTab _tab = NotificationTab.payment;
  List<AppNotification> _all = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  NotificationTab get tab => _tab;
  List<AppNotification> get all => _all;

  List<AppNotification> get filtered {
    switch (_tab) {
      case NotificationTab.payment:
        return _all.where((n) => (n.type ?? '').toLowerCase() == 'payment').toList();
      case NotificationTab.registration:
        return _all
            .where((n) => (n.type ?? '').toLowerCase() == 'registration')
            .where((n) => (n.status ?? '').toLowerCase() != 'rejected')
            .toList();
    }
  }

  Future<void> load({bool unreadOnly = false}) async {
    _setLoading(true);
    _error = null;
    try {
      // If we have a landlord id saved, prefer landlord-scoped endpoint
      final int? landlordId = await AuthService().getLandlordId();
      final List<NotificationDto> dtos = unreadOnly
          ? await _service.fetchUnread()
          : (landlordId != null ? await _service.fetchByLandlord(landlordId) : await _service.fetchAll());
      _all = dtos.map((e) => e.toDomain()).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void switchTab(NotificationTab value) {
    _tab = value;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    // Optimistically update UI
    final unread = _all.where((n) => !n.isRead).toList(growable: false);
    if (unread.isEmpty) return;

    _all = _all.map((n) => n.markAsRead()).toList(growable: false);
    notifyListeners();

    // Best-effort sync with server (sequentially)
    for (final n in unread) {
      try {
        final updated = await _service.markAsRead(n.id);
        _all = _all
            .map((x) => x.id == n.id ? updated.toDomain() : x)
            .toList(growable: false);
      } catch (_) {
        // If any call fails, keep optimistic state; next refresh will correct it
      }
    }
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    // Optimistic update
    _all = _all.map((n) => n.id == id ? n.markAsRead() : n).toList(growable: false);
    notifyListeners();

    try {
      final updated = await _service.markAsRead(id);
      _all = _all.map((n) => n.id == id ? updated.toDomain() : n).toList(growable: false);
      notifyListeners();
    } catch (e) {
      // Revert on failure by refetching that item via a cheap approach: reload list
      // If this is too heavy, we can store previous state and revert only that item
      _error = e.toString();
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
