import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/app_router.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/core/widgets/empty_view.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_notifier.dart';
import 'package:shopsphere/features/cart/presentation/providers/checkout_state.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_summary_card.dart';

/// Full shopping cart screen managing cart items, quantity adjustments,
/// price breakdown, and order checkout submission.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 768;

    // Listen for checkout failures to display accessible SnackBar alerts
    ref.listen<CheckoutState>(checkoutNotifierProvider, (previous, next) {
      if (next is CheckoutError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _handleCheckout(context, ref),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cartState.isNotEmpty
              ? 'Shopping Cart (${cartState.totalQuantity})'
              : 'Shopping Cart',
        ),
        actions: [
          if (cartState.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () => _confirmClearCart(context, ref),
            ),
        ],
      ),
      body: cartState.isEmpty
          ? EmptyView(
              title: 'Your cart is empty',
              message:
                  'Looks like you haven\'t added any items to your cart yet. Explore our catalogue and discover great products!',
              icon: Icons.remove_shopping_cart_outlined,
              action: FilledButton.icon(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Start Shopping'),
              ),
            )
          : isWideScreen
          ? _buildWideLayout(context, ref, cartState, checkoutState)
          : _buildMobileLayout(context, ref, cartState, checkoutState),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic cartState,
    CheckoutState checkoutState,
  ) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final isCheckingOut = checkoutState is CheckoutLoading;

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = cartState.items[index];
            return CartItemTile(
              key: ValueKey(item.product.id),
              item: item,
              onIncrement: () =>
                  cartNotifier.incrementQuantity(item.product.id),
              onDecrement: () =>
                  cartNotifier.decrementQuantity(item.product.id),
              onRemove: () => cartNotifier.removeItem(item.product.id),
            );
          }, childCount: cartState.items.length),
        ),
        SliverToBoxAdapter(
          child: CartSummaryCard(
            totals: cartState.totals,
            isCheckingOut: isCheckingOut,
            onCheckout: () => _handleCheckout(context, ref),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.space24)),
      ],
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic cartState,
    CheckoutState checkoutState,
  ) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final isCheckingOut = checkoutState is CheckoutLoading;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Cart items list (60%)
            Expanded(
              flex: 6,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: AppConstants.space8),
                itemCount: cartState.items.length,
                itemBuilder: (context, index) {
                  final item = cartState.items[index];
                  return CartItemTile(
                    key: ValueKey(item.product.id),
                    item: item,
                    onIncrement: () =>
                        cartNotifier.incrementQuantity(item.product.id),
                    onDecrement: () =>
                        cartNotifier.decrementQuantity(item.product.id),
                    onRemove: () => cartNotifier.removeItem(item.product.id),
                  );
                },
              ),
            ),

            // Right column: Sticky Order summary card (40%)
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.space16),
                child: CartSummaryCard(
                  totals: cartState.totals,
                  isCheckingOut: isCheckingOut,
                  onCheckout: () => _handleCheckout(context, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState is Authenticated ? authState.user.id : 1;
    final cartState = ref.read(cartNotifierProvider);

    if (cartState.isEmpty) return;

    final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    final success = await checkoutNotifier.processCheckout(
      userId: userId,
      items: cartState.items,
      onOrderConfirmed: () async {
        await cartNotifier.clearCart();
      },
    );

    if (success && context.mounted) {
      final state = ref.read(checkoutNotifierProvider);
      if (state is CheckoutSuccess) {
        context.go('/order-confirmation', extra: state.order);
      }
    }
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Shopping Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
