import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Material 3 Product Card displaying product thumbnail, title, pricing and rating.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = product.discountPercentage > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Cache and Error Fallback
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(50),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(50),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 36,
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (hasDiscount)
                    Positioned(
                      top: AppConstants.space8,
                      left: AppConstants.space8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.discount,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Rating Badge
                  Positioned(
                    top: AppConstants.space8,
                    right: AppConstants.space8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.rating,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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

            // Product Details Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand or Category
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 2),

                  // Title
                  Text(
                    product.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Pricing row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${product.discountedPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
