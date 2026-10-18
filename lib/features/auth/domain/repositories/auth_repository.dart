import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

/// Contract for Authentication repository in the domain layer.
abstract class AuthRepository {
  /// Authenticates user with username & password and securely stores tokens.
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// Validates the current stored session via GET /auth/me.
  Future<Result<User>> getCurrentUser();

  /// Checks if a non-empty access token is stored locally.
  Future<Result<bool>> hasSession();

  /// Clears stored tokens and resets session state.
  Future<Result<void>> logout();
}
