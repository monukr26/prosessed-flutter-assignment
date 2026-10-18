import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_order.dart';
import 'package:shopsphere/features/cart/domain/repositories/checkout_repository.dart';

/// Use case to submit cart items and create a simulated order on DummyJSON.
class CheckoutUseCase {
  final CheckoutRepository _repository;

  const CheckoutUseCase(this._repository);

  Future<Result<CheckoutOrder>> call({
    required int userId,
    required List<CartItem> items,
  }) {
    return _repository.checkout(userId: userId, items: items);
  }
}
