import 'package:flutter/material.dart';
import 'package:app/domain/models/contract/contract_model.dart';
import 'package:app/domain/repositories/contract_repository.dart';

/// ViewModel for managing room contracts.
/// Handles fetching active contract and tenant information for a room.
class ContractViewModel extends ChangeNotifier {
  final ContractRepository _repository;

  ContractViewModel(this._repository);

  // State
  ContractModel? _contract;
  bool _isLoading = false;
  String? _error;

  // Getters
  ContractModel? get contract => _contract;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasContract => _contract != null;

  /// Load active contract for a specific room
  Future<void> loadActiveContract(int roomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contract = await _repository.fetchActiveContract(roomId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _contract = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all data
  void clear() {
    _contract = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
