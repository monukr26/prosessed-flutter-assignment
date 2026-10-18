import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/app_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_order.dart';

/// Screen displayed after a successfully simulated checkout.
class OrderConfirmationScreen extends StatelessWidget {
  final CheckoutOrder order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Done',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 720 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success banner card
                Card(
                  elevation: 0,
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    side: BorderSide(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.space24,
                      horizontal: AppConstants.space16,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space16),
                        Text(
                          'Order Placed Successfully!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.space8),
                        Text(
                          'Order #${order.id} • Authenticated User ID: ${order.userId}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space16),

                // Simulation note alert
                Container(
                  padding: const EdgeInsets.all(AppConstants.space12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.space12),
                      Expanded(
                        child: Text(
                          'Note: DummyJSON is a simulated mock API for development testing. '
                          'Your checkout request was validated and received by the server, but '
                          'no financial charge or permanent order was stored.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),

                // Ordered products card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items in this Order (${order.totalQuantity})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space12),
                        const Divider(),
                        ...order.products.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.space8,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radius8,
                                  ),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: item.thumbnail.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: item.thumbnail,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 20,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.shopping_bag_outlined,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item.discountedTotal.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space16),

                // Order Totals Summary Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    child: Column(
                      children: [
                        _buildTotalRow(
                          context,
                          'Subtotal',
                          order.formattedTotal,
                        ),
                        if (order.totalDiscount > 0) ...[
                          const SizedBox(height: AppConstants.space8),
                          _buildTotalRow(
                            context,
                            'Discounts',
                            '- ${order.formattedDiscount}',
                            color: AppColors.success,
                          ),
                        ],
                        const SizedBox(height: AppConstants.space8),
                        const Divider(),
                        const SizedBox(height: AppConstants.space8),
                        _buildTotalRow(
                          context,
                          'Total Paid',
                          order.formattedDiscountedTotal,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space24),

                // Continue Shopping Action
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Continue Shopping'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isBold ? theme.colorScheme.primary : null),
            fontSize: isBold ? 16 : null,
          ),
        ),
      ],
    );
  }
}
