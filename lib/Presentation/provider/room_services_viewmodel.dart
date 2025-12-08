import 'package:flutter/material.dart';
import 'package:app/domain/models/settings/service_model.dart';
import 'package:app/domain/repositories/room_services_repository.dart';

/// ViewModel for managing room services (facilities).
/// Handles fetching, attaching, and detaching services from rooms.
class RoomServicesViewModel extends ChangeNotifier {
  final RoomServicesRepository _repository;

  RoomServicesViewModel(this._repository);

  // State
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasServices => _services.isNotEmpty;

  /// Load all services for a specific room
  Future<void> loadRoomServices(int roomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _repository.fetchRoomServices(roomId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _services = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Attach a service to a room
  Future<bool> attachService(int roomId, int serviceId) async {
    try {
      final service = await _repository.attachService(roomId, serviceId);
      _services.add(service);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Detach a service from a room
  Future<bool> detachService(int roomId, int serviceId) async {
    try {
      await _repository.detachService(roomId, serviceId);
      _services.removeWhere((s) => s.id == serviceId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear all data
  void clear() {
    _services = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}