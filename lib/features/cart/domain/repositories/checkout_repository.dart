import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_order.dart';

/// Repository interface for simulating checkout order creation.
///
/// Pure Dart contract decoupled from networking and HTTP libraries.
abstract class CheckoutRepository {
  /// Submits the current cart items to POST /carts/add for [userId].
  Future<Result<CheckoutOrder>> checkout({
    required int userId,
    required List<CartItem> items,
  });
}
