import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Explicit status of the product details state.
enum ProductDetailsStatus { initial, loading, success, notFound, error }

/// Immutable state representing product details view, selection and quantity.
class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final Product? product;
  final int quantity;
  final String? errorMessage;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.quantity = 1,
    this.errorMessage,
  });

  bool get isLoading => status == ProductDetailsStatus.loading;
  bool get isNotFound => status == ProductDetailsStatus.notFound;
  bool get isError => status == ProductDetailsStatus.error;
  bool get isSuccess =>
      status == ProductDetailsStatus.success && product != null;
  bool get isOutOfStock => product != null && !product!.isInStock;

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    Product? product,
    int? quantity,
    String? errorMessage,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, quantity, errorMessage];
}
