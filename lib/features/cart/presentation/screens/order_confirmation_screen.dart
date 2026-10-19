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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Done',
            constraints: const BoxConstraints(
              minWidth: AppConstants.minTouchTarget,
              minHeight: AppConstants.minTouchTarget,
            ),
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go(AppRoutes.home),
          ),
          const SizedBox(width: AppConstants.space8),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.space24,
                    horizontal: AppConstants.space16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF064E3B)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 1,
                    ),
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
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF14532D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF047857)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Order #${order.id} • User ID: ${order.userId}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),

                // Simulation note alert
                Container(
                  padding: const EdgeInsets.all(AppConstants.space12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                    border: Border.all(color: theme.colorScheme.outline),
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
                          'Your checkout request was validated and confirmed by the server, but '
                          'no financial charge or permanent order was processed.',
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
                Container(
                  padding: const EdgeInsets.all(AppConstants.space16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items in this Order (${order.totalQuantity})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
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
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF9FAFB),
                                  padding: const EdgeInsets.all(4),
                                  child: item.thumbnail.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: item.thumbnail,
                                          fit: BoxFit.contain,
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                size: 20,
                                              ),
                                        )
                                      : const Icon(Icons.shopping_bag_outlined),
                                ),
                              ),
                              const SizedBox(width: AppConstants.space12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(height: 2),
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
                                '\$${item.total.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),

                // Order totals card
                Container(
                  padding: const EdgeInsets.all(AppConstants.space16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radius16),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        context,
                        'Subtotal',
                        '\$${order.total.toStringAsFixed(2)}',
                      ),
                      if (order.total > order.discountedTotal) ...[
                        const SizedBox(height: AppConstants.space8),
                        _buildSummaryRow(
                          context,
                          'Promotional Savings',
                          '- \$${(order.total - order.discountedTotal).toStringAsFixed(2)}',
                          isDiscount: true,
                        ),
                      ],
                      const SizedBox(height: AppConstants.space8),
                      const Divider(),
                      const SizedBox(height: AppConstants.space8),
                      _buildSummaryRow(
                        context,
                        'Total Paid',
                        '\$${order.discountedTotal.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space24),

                // Continue Shopping Action
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text('Continue Shopping'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radius12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
            color: isDiscount
                ? AppColors.success
                : isTotal
                ? theme.colorScheme.primary
                : null,
          ),
        ),
      ],
    );
  }
}
