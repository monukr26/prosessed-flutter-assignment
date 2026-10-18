import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Encapsulates paginated product results with pagination metadata.
class PaginatedProducts extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  /// True if more items can be loaded based on total and current offset.
  bool get hasMore => (skip + products.length) < total;

  @override
  List<Object?> get props => [products, total, skip, limit];
}
