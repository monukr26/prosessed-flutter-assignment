import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';

/// Repository interface for shopping cart persistence.
///
/// Pure Dart contract decoupled from storage implementation details.
abstract class CartRepository {
  /// Loads persisted cart items from local cache.
  Future<Result<List<CartItem>>> getCart();

  /// Persists the active list of cart items to local cache.
  Future<Result<void>> saveCart(List<CartItem> items);

  /// Clears all cart items from local cache.
  Future<Result<void>> clearCart();
}
