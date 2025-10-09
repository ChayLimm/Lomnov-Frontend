import 'package:app/data/repositories/auth_repository.dart';
import 'package:app/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool _loading = false;
  String? _error;
  UserModel? _user;

  bool get loading => _loading;
  String? get error => _error;
  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.login(email, password);
      if (_user != null) {
        // Delay to ensure listeners finish building frames before navigation
        Future.microtask(() => Get.offAllNamed('/home'));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repo.register(name, email, password);
      if (_user != null) {
        Future.microtask(() => Get.offAllNamed('/home'));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
