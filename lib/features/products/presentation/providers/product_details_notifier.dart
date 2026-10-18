import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:shopsphere/features/products/presentation/providers/product_details_state.dart';

/// Riverpod Notifier managing state and quantity for a specific product ID.
class ProductDetailsNotifier extends Notifier<ProductDetailsState> {
  final int productId;
  final GetProductDetailsUseCase? _injectedUseCase;
  late final GetProductDetailsUseCase _useCase;

  ProductDetailsNotifier(this.productId, [this._injectedUseCase]);

  @override
  ProductDetailsState build() {
    _useCase = _injectedUseCase ?? sl<GetProductDetailsUseCase>();

    // Kick off product details fetch asynchronously on build
    Future.microtask(() => loadProduct());

    return const ProductDetailsState(status: ProductDetailsStatus.loading);
  }

  /// Fetches complete details for [productId] handling notFound, network and server failures.
  Future<void> loadProduct([int? id]) async {
    final targetId = id ?? productId;

    state = state.copyWith(
      status: ProductDetailsStatus.loading,
      errorMessage: null,
    );

    final result = await _useCase(targetId);

    result.when(
      success: (product) {
        state = state.copyWith(
          status: ProductDetailsStatus.success,
          product: product,
          quantity: product.isInStock ? 1 : 0,
        );
      },
      failure: (failure) {
        if (failure is NotFoundFailure || failure.statusCode == 404) {
          state = state.copyWith(
            status: ProductDetailsStatus.notFound,
            errorMessage:
                'Product not found. The item you are looking for may have been removed or does not exist.',
          );
        } else {
          state = state.copyWith(
            status: ProductDetailsStatus.error,
            errorMessage: failure.message,
          );
        }
      },
    );
  }

  /// Increments quantity respecting available stock.
  void incrementQuantity() {
    final product = state.product;
    if (product == null || !product.isInStock) return;

    if (state.quantity < product.stock) {
      state = state.copyWith(quantity: state.quantity + 1);
    }
  }

  /// Decrements quantity with a minimum boundary of 1.
  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }
}

/// Global provider for ProductDetailsNotifier parametrized by product ID.
final productDetailsNotifierProvider =
    NotifierProvider.family<ProductDetailsNotifier, ProductDetailsState, int>(
      (id) => ProductDetailsNotifier(id),
    );
