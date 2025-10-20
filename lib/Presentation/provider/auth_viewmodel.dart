import 'package:app/data/repositories/auth_repository.dart';
import 'package:app/domain/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/domain/services/auth_service.dart';

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
        // Persist landlord_id = user.id for downstream services
        await AuthService().setLandlordId(_user!.id);
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
        await AuthService().setLandlordId(_user!.id);
        Future.microtask(() => Get.offAllNamed('/home'));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Clear persisted auth (token + landlord id)
    await AuthService().logout();
    // Clear in-memory user and errors
    _user = null;
    _error = null;
    notifyListeners();
    // Navigate to login/root
    if (Get.currentRoute != '/' && Get.currentRoute.isNotEmpty) {
      Get.offAllNamed('/');
    }
  }
}
