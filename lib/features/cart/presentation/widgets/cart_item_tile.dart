import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';

/// Presentation card displaying a single cart item with thumbnail, pricing,
/// accessible quantity controls, and delete action.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;
    final isAtMaxStock = item.quantity >= product.stock;
    final isAtMinQuantity = item.quantity <= 1;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius14),
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image container
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radius10),
              child: Container(
                width: 84,
                height: 84,
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF9FAFB),
                padding: const EdgeInsets.all(AppConstants.space4),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.space12),

            // Details and quantity controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and remove action
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        tooltip: 'Remove from cart',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppConstants.minTouchTarget,
                          minHeight: AppConstants.minTouchTarget,
                        ),
                        onPressed: onRemove,
                      ),
                    ],
                  ),

                  // Brand / Category caption
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: AppConstants.space8),

                  // Price & Quantity controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Unit Price & Line Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${item.lineTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (product.discountPercentage > 0)
                            Text(
                              '\$${item.lineSubtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),

                      // Quantity modifier controls with accessible 48dp touch targets
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radius10,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_rounded, size: 16),
                              tooltip: 'Decrease quantity',
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              onPressed: isAtMinQuantity ? null : onDecrement,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.space8,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 16),
                              tooltip: 'Increase quantity',
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              onPressed: isAtMaxStock ? null : onIncrement,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
