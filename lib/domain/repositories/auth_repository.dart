import 'package:app/domain/models/user_model.dart';

/// Abstract repository interface for authentication operations.
/// 
/// Defines the contract for authentication-related operations
/// that must be implemented by concrete repository classes.
abstract class AuthRepository {
  /// Registers a new user with the provided credentials.
  /// 
  /// Returns a [UserModel] representing the newly registered user.
  /// Throws an [Exception] if registration fails.
  Future<UserModel> register(String name, String email, String password);

  /// Authenticates a user with email and password.
  /// 
  /// Returns a [UserModel] representing the authenticated user.
  /// Throws an [Exception] if login fails.
  Future<UserModel> login(String email, String password);

  /// Logs out the current user.
  /// 
  /// Clears authentication tokens and user session data.
  Future<void> logout();

  /// Checks if a user is currently logged in.
  /// 
  /// Returns `true` if a valid authentication token exists.
  Future<bool> isLoggedIn();

  /// Gets the current authentication token.
  /// 
  /// Returns the token string or `null` if not authenticated.
  Future<String?> getToken();

  /// Gets the current landlord ID.
  /// 
  /// Returns the landlord ID or `null` if not set.
  Future<int?> getLandlordId();
}
