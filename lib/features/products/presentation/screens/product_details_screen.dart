import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/core/widgets/empty_view.dart';
import 'package:shopsphere/core/widgets/error_view.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/providers/product_details_notifier.dart';
import 'package:shopsphere/features/products/presentation/providers/product_details_state.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_details_skeleton.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_image_carousel.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_quantity_selector.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_reviews_list.dart';

/// Product details screen displaying images, pricing, reviews, stock & quantity selector.
class ProductDetailsScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(productDetailsNotifierProvider(productId));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Catalogue',
          onPressed: () => context.pop(),
        ),
        title: Text(
          state.product?.title ?? 'Product Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: switch (state.status) {
        ProductDetailsStatus.initial ||
        ProductDetailsStatus.loading => const ProductDetailsSkeleton(),
        ProductDetailsStatus.notFound => EmptyView(
          title: 'Product Not Found',
          message:
              state.errorMessage ??
              'The product you are looking for does not exist.',
          icon: Icons.search_off_rounded,
          action: FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Catalogue'),
          ),
        ),
        ProductDetailsStatus.error => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ErrorView(
                message:
                    state.errorMessage ?? 'Failed to load product details.',
                onRetry: () {
                  ref
                      .read(productDetailsNotifierProvider(productId).notifier)
                      .loadProduct(productId);
                },
              ),
              const SizedBox(height: AppConstants.space8),
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Return to Catalogue'),
              ),
            ],
          ),
        ),
        ProductDetailsStatus.success => _buildContent(
          context,
          ref,
          state,
          state.product!,
          isWideScreen,
          theme,
        ),
      },
      bottomNavigationBar: state.isSuccess
          ? _buildBottomBar(context, ref, state, state.product!, theme)
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ProductDetailsState state,
    Product product,
    bool isWideScreen,
    ThemeData theme,
  ) {
    final carousel = ProductImageCarousel(
      images: product.images,
      fallbackThumbnail: product.thumbnail,
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand tag (if available)
        if (product.brand != null && product.brand!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              product.brand!,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space8),
        ],

        // Title
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.space8),

        // Rating & Review count badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.rating.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.rating,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.space8),
            Text(
              '(${product.reviews.length} customer reviews)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.space16),

        // Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$${product.discountedPrice.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (product.discountPercentage > 0) ...[
              const SizedBox(width: AppConstants.space12),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppConstants.space8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.discount,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppConstants.space16),

        // Stock status
        _buildStockStatus(product, theme),
        const SizedBox(height: AppConstants.space20),

        // Description Section
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          product.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.space24),

        // Customer Reviews Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${product.reviews.length} total',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.space12),
        ProductReviewsList(reviews: product.reviews),
        const SizedBox(height: AppConstants.space24),
      ],
    );

    if (isWideScreen) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: carousel),
            const SizedBox(width: AppConstants.space32),
            Expanded(flex: 6, child: details),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          carousel,
          const SizedBox(height: AppConstants.space16),
          details,
        ],
      ),
    );
  }

  Widget _buildStockStatus(Product product, ThemeData theme) {
    if (!product.isInStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 16,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 6),
            Text(
              'Out of Stock',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final isLowStock = product.stock < 5;
    final color = isLowStock ? AppColors.secondary : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            isLowStock
                ? 'Only ${product.stock} left in stock'
                : 'In Stock (${product.stock} available)',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    ProductDetailsState state,
    Product product,
    ThemeData theme,
  ) {
    final notifier = ref.read(
      productDetailsNotifierProvider(productId).notifier,
    );
    final totalPrice = product.discountedPrice * state.quantity;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            ProductQuantitySelector(
              quantity: state.quantity,
              maxStock: product.stock,
              onIncrement: notifier.incrementQuantity,
              onDecrement: notifier.decrementQuantity,
            ),
            const SizedBox(width: AppConstants.space12),

            // Add to Cart Button
            Expanded(
              child: FilledButton.icon(
                onPressed: state.isOutOfStock
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${state.quantity}x ${product.title} to cart (\$$totalPrice). Cart persistence in next milestone.',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  state.isOutOfStock
                      ? 'Out of Stock'
                      : 'Add to Cart • \$${totalPrice.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
