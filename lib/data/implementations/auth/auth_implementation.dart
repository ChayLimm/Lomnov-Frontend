import 'package:app/data/services/auth_service.dart';
import 'package:app/domain/models/user_model.dart';
import 'package:app/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using [AuthService].
///
/// This class provides concrete implementations of authentication operations
/// by delegating to the [AuthService] and transforming responses into domain models.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service = AuthService();

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final Map<String, dynamic> res = await _service.register({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    final userJson = (res['user'] is Map<String, dynamic>)
        ? res['user'] as Map<String, dynamic>
        : res;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final Map<String, dynamic> res = await _service.login({
      'email': email,
      'password': password,
    });
    final userJson = (res['user'] is Map<String, dynamic>)
        ? res['user'] as Map<String, dynamic>
        : res;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<void> logout() async {
    await _service.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _service.isLoggedIn();
  }

  @override
  Future<String?> getToken() async {
    return await _service.getToken();
  }

  @override
  Future<int?> getLandlordId() async {
    return await _service.getLandlordId();
  }
}
