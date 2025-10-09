import 'package:app/domain/models/user_model.dart';
import 'package:app/domain/services/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

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
}
