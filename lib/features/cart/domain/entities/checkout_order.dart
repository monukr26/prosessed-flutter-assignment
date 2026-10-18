import 'package:equatable/equatable.dart';

/// Pure domain entity representing an item within a completed checkout order.
class CheckoutOrderItem extends Equatable {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  const CheckoutOrderItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    quantity,
    total,
    discountPercentage,
    discountedTotal,
    thumbnail,
  ];
}

/// Pure domain entity representing a simulated order returned from checkout.
class CheckoutOrder extends Equatable {
  final int id;
  final int userId;
  final List<CheckoutOrderItem> products;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;

  const CheckoutOrder({
    required this.id,
    required this.userId,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.totalProducts,
    required this.totalQuantity,
  });

  /// Total discount saved.
  double get totalDiscount {
    final diff = total - discountedTotal;
    return diff > 0 ? diff : 0.0;
  }

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
  String get formattedDiscountedTotal =>
      '\$${discountedTotal.toStringAsFixed(2)}';
  String get formattedDiscount => '\$${totalDiscount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
    id,
    userId,
    products,
    total,
    discountedTotal,
    totalProducts,
    totalQuantity,
  ];
}
