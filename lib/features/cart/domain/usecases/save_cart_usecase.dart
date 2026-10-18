import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';

/// Use case to persist active cart items to local cache.
class SaveCartUseCase {
  final CartRepository _repository;

  const SaveCartUseCase(this._repository);

  Future<Result<void>> call(List<CartItem> items) {
    return _repository.saveCart(items);
  }
}
