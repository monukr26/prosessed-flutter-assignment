import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_totals.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/save_cart_usecase.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_state.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Riverpod Notifier managing shopping cart modifications, quantity bounds,
/// totals calculation and asynchronous local persistence.
class CartNotifier extends Notifier<CartState> {
  final GetCartUseCase? _injectedGetCartUseCase;
  final SaveCartUseCase? _injectedSaveCartUseCase;
  final ClearCartUseCase? _injectedClearCartUseCase;

  late final GetCartUseCase _getCartUseCase;
  late final SaveCartUseCase _saveCartUseCase;
  late final ClearCartUseCase _clearCartUseCase;

  CartNotifier({
    GetCartUseCase? getCartUseCase,
    SaveCartUseCase? saveCartUseCase,
    ClearCartUseCase? clearCartUseCase,
  }) : _injectedGetCartUseCase = getCartUseCase,
       _injectedSaveCartUseCase = saveCartUseCase,
       _injectedClearCartUseCase = clearCartUseCase;

  @override
  CartState build() {
    _getCartUseCase = _injectedGetCartUseCase ?? sl<GetCartUseCase>();
    _saveCartUseCase = _injectedSaveCartUseCase ?? sl<SaveCartUseCase>();
    _clearCartUseCase = _injectedClearCartUseCase ?? sl<ClearCartUseCase>();

    // Asynchronously restore cached cart on initialization
    Future.microtask(loadCart);

    return CartState.initial();
  }

  /// Restores cart items from persistent local cache.
  Future<void> loadCart() async {
    if (state.items.isNotEmpty) return;
    state = state.copyWith(status: CartStatus.loading);
    final result = await _getCartUseCase();

    result.when(
      success: (items) {
        if (state.items.isNotEmpty) return;
        state = CartState(
          status: CartStatus.loaded,
          items: items,
          totals: CartTotals.calculate(items),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Adds a product with [quantity] into the cart.
  ///
  /// - Prevents adding unavailable or out-of-stock items (`stock <= 0`).
  /// - Avoids duplicates by updating existing item quantity instead.
  /// - Clamps maximum quantity to available [product.stock].
  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (!product.isInStock || product.stock <= 0 || quantity <= 0) {
      return false;
    }

    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final existingItem = currentItems[existingIndex];
      final newQuantity = min(existingItem.quantity + quantity, product.stock);
      currentItems[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
      );
    } else {
      final actualQuantity = min(quantity, product.stock);
      currentItems.add(CartItem(product: product, quantity: actualQuantity));
    }

    _updateCartState(currentItems);
    await _saveCartUseCase(currentItems);
    return true;
  }

  /// Increments quantity for item [productId], capped at available product stock.
  Future<void> incrementQuantity(int productId) async {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == productId,
    );
    if (index == -1) return;

    final item = currentItems[index];
    if (item.quantity >= item.product.stock) {
      return; // Capped at available stock
    }

    currentItems[index] = item.copyWith(quantity: item.quantity + 1);
    _updateCartState(currentItems);
    await _saveCartUseCase(currentItems);
  }

  /// Decrements quantity for item [productId], strictly preventing quantities < 1.
  Future<void> decrementQuantity(int productId) async {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == productId,
    );
    if (index == -1) return;

    final item = currentItems[index];
    if (item.quantity <= 1) {
      return; // Strictly enforce minimum quantity of 1
    }

    currentItems[index] = item.copyWith(quantity: item.quantity - 1);
    _updateCartState(currentItems);
    await _saveCartUseCase(currentItems);
  }

  /// Removes an item completely from the cart.
  Future<void> removeItem(int productId) async {
    final currentItems = state.items
        .where((item) => item.product.id != productId)
        .toList();

    _updateCartState(currentItems);
    await _saveCartUseCase(currentItems);
  }

  /// Empties the entire cart and clears local storage.
  Future<void> clearCart() async {
    state = CartState(
      status: CartStatus.loaded,
      items: const [],
      totals: CartTotals.empty(),
    );
    await _clearCartUseCase();
  }

  void _updateCartState(List<CartItem> items) {
    state = CartState(
      status: CartStatus.loaded,
      items: items,
      totals: CartTotals.calculate(items),
    );
  }
}

/// Global provider for the shared shopping cart.
final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
