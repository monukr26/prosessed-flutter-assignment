import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';

/// Pure domain entity encapsulating price breakdowns and quantity summaries for a cart.
class CartTotals extends Equatable {
  /// Sum of original prices before discounts.
  final double subtotal;

  /// Total discount saved across all items.
  final double totalDiscount;

  /// Final payable amount after applying discounts.
  final double grandTotal;

  /// Total count of all items (sum of quantities).
  final int totalItems;

  /// Number of distinct product lines.
  final int totalUniqueProducts;

  const CartTotals({
    required this.subtotal,
    required this.totalDiscount,
    required this.grandTotal,
    required this.totalItems,
    required this.totalUniqueProducts,
  });

  /// Factory creating zeroed totals for an empty cart.
  factory CartTotals.empty() {
    return const CartTotals(
      subtotal: 0.0,
      totalDiscount: 0.0,
      grandTotal: 0.0,
      totalItems: 0,
      totalUniqueProducts: 0,
    );
  }

  /// Calculates aggregated totals from a list of [CartItem]s.
  ///
  /// Prevents double discounting by deriving [totalDiscount] strictly from
  /// the difference between [subtotal] and [grandTotal].
  factory CartTotals.calculate(List<CartItem> items) {
    if (items.isEmpty) {
      return CartTotals.empty();
    }

    double rawSubtotal = 0.0;
    double rawGrandTotal = 0.0;
    int itemsCount = 0;

    for (final item in items) {
      rawSubtotal += item.lineSubtotal;
      rawGrandTotal += item.lineTotal;
      itemsCount += item.quantity;
    }

    final calculatedDiscount = rawSubtotal - rawGrandTotal;
    final totalDiscount = calculatedDiscount > 0 ? calculatedDiscount : 0.0;

    return CartTotals(
      subtotal: rawSubtotal,
      totalDiscount: totalDiscount,
      grandTotal: rawGrandTotal,
      totalItems: itemsCount,
      totalUniqueProducts: items.length,
    );
  }

  /// Formatted subtotal with 2 decimal places.
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  /// Formatted discount with 2 decimal places.
  String get formattedDiscount => '\$${totalDiscount.toStringAsFixed(2)}';

  /// Formatted grand total with 2 decimal places.
  String get formattedGrandTotal => '\$${grandTotal.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
    subtotal,
    totalDiscount,
    grandTotal,
    totalItems,
    totalUniqueProducts,
  ];
}
