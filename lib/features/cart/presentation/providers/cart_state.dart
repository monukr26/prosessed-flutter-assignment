import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_totals.dart';

enum CartStatus { initial, loading, loaded, error }

/// Immutable state representing active shopping cart data and pricing calculations.
class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final CartTotals totals;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    required this.totals,
    this.errorMessage,
  });

  factory CartState.initial() {
    return CartState(
      status: CartStatus.initial,
      items: const [],
      totals: CartTotals.empty(),
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get totalQuantity => totals.totalItems;

  bool isInCart(int productId) => items.any((i) => i.product.id == productId);

  int getQuantity(int productId) {
    for (final item in items) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    CartTotals? totals,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      totals: totals ?? this.totals,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, totals, errorMessage];
}
