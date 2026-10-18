import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';

/// Use case to retrieve persisted cart items from local cache.
class GetCartUseCase {
  final CartRepository _repository;

  const GetCartUseCase(this._repository);

  Future<Result<List<CartItem>>> call() {
    return _repository.getCart();
  }
}
