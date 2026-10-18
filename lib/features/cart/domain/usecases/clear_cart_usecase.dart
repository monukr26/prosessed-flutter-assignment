import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';

/// Use case to clear all cart items from local cache.
class ClearCartUseCase {
  final CartRepository _repository;

  const ClearCartUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.clearCart();
  }
}
