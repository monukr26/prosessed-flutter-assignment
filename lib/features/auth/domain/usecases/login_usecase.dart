import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

/// Use case to authenticate a user with credentials.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<User>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
