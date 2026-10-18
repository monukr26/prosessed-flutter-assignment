import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Data Transfer Object for [CartItem].
///
/// Handles robust serialization and deserialization for local persistence.
class CartItemModel extends CartItem {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    final Product product;
    if (rawProduct is Map<String, dynamic>) {
      product = ProductModel.fromJson(rawProduct);
    } else {
      product = ProductModel.fromJson(const {});
    }

    final rawQuantity = json['quantity'];
    final quantity = (rawQuantity as num?)?.toInt() ?? 1;

    return CartItemModel(
      product: product,
      quantity: quantity > 0 ? quantity : 1,
    );
  }

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(product: entity.product, quantity: entity.quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'product': ProductModel.fromEntity(product).toJson(),
      'quantity': quantity,
    };
  }
}
