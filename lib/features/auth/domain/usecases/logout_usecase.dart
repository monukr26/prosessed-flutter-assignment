import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

/// Use case to securely log out and clear stored session tokens.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
