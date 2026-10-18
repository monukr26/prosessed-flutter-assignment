import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Pure domain entity representing an individual item within the shopping cart.
class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  /// Original line total before discounts.
  double get lineSubtotal => product.price * quantity;

  /// Effective line total after applying the product's discount.
  double get lineTotal => product.discountedPrice * quantity;

  /// Absolute monetary discount for this line item.
  double get lineDiscount => lineSubtotal - lineTotal;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}
