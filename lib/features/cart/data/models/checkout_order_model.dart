import 'package:shopsphere/features/cart/domain/entities/checkout_order.dart';

/// Data Transfer Object for an individual ordered product item returned from DummyJSON.
class CheckoutOrderItemModel extends CheckoutOrderItem {
  const CheckoutOrderItemModel({
    required super.id,
    required super.title,
    required super.price,
    required super.quantity,
    required super.total,
    required super.discountPercentage,
    required super.discountedTotal,
    required super.thumbnail,
  });

  factory CheckoutOrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = (json['total'] as num?)?.toDouble() ?? 0.0;
    final rawDiscounted =
        (json['discountedTotal'] ?? json['discountedPrice'] as num?)
            ?.toDouble() ??
        rawTotal;

    return CheckoutOrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      total: rawTotal,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: rawDiscounted,
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }
}

/// Data Transfer Object for [CheckoutOrder].
class CheckoutOrderModel extends CheckoutOrder {
  const CheckoutOrderModel({
    required super.id,
    required super.userId,
    required super.products,
    required super.total,
    required super.discountedTotal,
    required super.totalProducts,
    required super.totalQuantity,
  });

  factory CheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? const [];
    final products = rawProducts
        .whereType<Map<String, dynamic>>()
        .map(CheckoutOrderItemModel.fromJson)
        .toList();

    final total = (json['total'] as num?)?.toDouble() ?? 0.0;
    final discountedTotal =
        (json['discountedTotal'] as num?)?.toDouble() ?? total;

    return CheckoutOrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      products: products,
      total: total,
      discountedTotal: discountedTotal,
      totalProducts:
          (json['totalProducts'] as num?)?.toInt() ?? products.length,
      totalQuantity:
          (json['totalQuantity'] as num?)?.toInt() ??
          products.fold(0, (sum, p) => sum + p.quantity),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'products': products
          .map(
            (p) =>
                (p is CheckoutOrderItemModel
                        ? p
                        : CheckoutOrderItemModel(
                            id: p.id,
                            title: p.title,
                            price: p.price,
                            quantity: p.quantity,
                            total: p.total,
                            discountPercentage: p.discountPercentage,
                            discountedTotal: p.discountedTotal,
                            thumbnail: p.thumbnail,
                          ))
                    .toJson(),
          )
          .toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}
