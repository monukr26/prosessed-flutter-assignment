import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

/// Use case to validate the active session and retrieve the user profile.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<Result<User>> call() {
    return _repository.getCurrentUser();
  }
}
