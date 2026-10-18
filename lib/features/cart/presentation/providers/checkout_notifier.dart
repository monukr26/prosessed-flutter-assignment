import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/usecases/checkout_usecase.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_state.dart';

/// Riverpod Notifier managing checkout lifecycle, preventing duplicate requests,
/// and coordinating cart cleanup on confirmed success.
class CheckoutNotifier extends Notifier<CheckoutState> {
  final CheckoutUseCase? _injectedCheckoutUseCase;
  late final CheckoutUseCase _checkoutUseCase;

  CheckoutNotifier({CheckoutUseCase? checkoutUseCase})
    : _injectedCheckoutUseCase = checkoutUseCase;

  @override
  CheckoutState build() {
    _checkoutUseCase = _injectedCheckoutUseCase ?? sl<CheckoutUseCase>();
    return const CheckoutInitial();
  }

  /// Processes checkout order submission for [userId] with the given [items].
  ///
  /// - Prevents concurrent / duplicate submissions while in [CheckoutLoading].
  /// - On success, triggers [onOrderConfirmed] callback to clear the local cart.
  /// - On failure, preserves the local cart and transitions to [CheckoutError].
  Future<bool> processCheckout({
    required int userId,
    required List<CartItem> items,
    required AsyncCallback onOrderConfirmed,
  }) async {
    // Prevent duplicate submissions
    if (state is CheckoutLoading) {
      return false;
    }

    if (items.isEmpty) {
      state = const CheckoutError('Cannot checkout with an empty cart.');
      return false;
    }

    state = const CheckoutLoading();

    final result = await _checkoutUseCase(userId: userId, items: items);

    return result.when(
      success: (order) async {
        try {
          await onOrderConfirmed();
        } catch (_) {
          // Failure to clear local cache should not block order confirmation
        }
        state = CheckoutSuccess(order);
        return true;
      },
      failure: (failure) {
        state = CheckoutError(failure.message);
        return false;
      },
    );
  }

  /// Resets state back to initial.
  void reset() {
    state = const CheckoutInitial();
  }
}

/// Global provider for the checkout process.
final checkoutNotifierProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);
