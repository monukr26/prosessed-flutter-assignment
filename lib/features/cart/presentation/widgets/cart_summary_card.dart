import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_totals.dart';

/// Card summarizing order totals, discounts and primary checkout action.
class CartSummaryCard extends StatelessWidget {
  final CartTotals totals;
  final bool isCheckingOut;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.totals,
    required this.isCheckingOut,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(AppConstants.space16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.space16),

            // Subtotal row
            _buildRow(
              context,
              label: 'Subtotal (${totals.totalItems} items)',
              value: totals.formattedSubtotal,
            ),
            const SizedBox(height: AppConstants.space8),

            // Discount row
            if (totals.totalDiscount > 0) ...[
              _buildRow(
                context,
                label: 'Promotional Savings',
                value: '- ${totals.formattedDiscount}',
                valueColor: AppColors.success,
              ),
              const SizedBox(height: AppConstants.space8),
            ],

            const Divider(),
            const SizedBox(height: AppConstants.space8),

            // Grand Total row
            _buildRow(
              context,
              label: 'Grand Total',
              value: totals.formattedGrandTotal,
              isBold: true,
              valueSize: 18,
            ),
            const SizedBox(height: AppConstants.space16),

            // Checkout CTA Button
            FilledButton.icon(
              onPressed: isCheckingOut || totals.totalItems == 0
                  ? null
                  : onCheckout,
              icon: isCheckingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_outline_rounded),
              label: Text(
                isCheckingOut
                    ? 'Processing Order...'
                    : 'Checkout • ${totals.formattedGrandTotal}',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.space12),

            // Disclaimer banner
            Container(
              padding: const EdgeInsets.all(AppConstants.space8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radius8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppConstants.space8),
                  Expanded(
                    child: Text(
                      'DummyJSON simulates order creation. No real transactions or shipments occur.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
    double? valueSize,
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
            fontSize: valueSize,
            color: valueColor ?? (isBold ? theme.colorScheme.primary : null),
          ),
        ),
      ],
    );
  }
}
