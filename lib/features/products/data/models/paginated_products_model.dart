import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';

/// Data Transfer Object for [PaginatedProducts].
class PaginatedProductsModel extends PaginatedProducts {
  const PaginatedProductsModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory PaginatedProductsModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? const [];
    final products = rawProducts
        .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final total = (json['total'] as num?)?.toInt() ?? products.length;
    final skip = (json['skip'] as num?)?.toInt() ?? 0;
    final limit = (json['limit'] as num?)?.toInt() ?? products.length;

    return PaginatedProductsModel(
      products: products,
      total: total,
      skip: skip,
      limit: limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products
          .map((p) => ProductModel.fromEntity(p).toJson())
          .toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
