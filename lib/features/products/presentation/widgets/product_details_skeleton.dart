import 'package:flutter/material.dart';
import 'package:shopsphere/core/utils/constants.dart';

/// Shimmer skeleton displayed while product details are loading.
class ProductDetailsSkeleton extends StatefulWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  State<ProductDetailsSkeleton> createState() => _ProductDetailsSkeletonState();
}

class _ProductDetailsSkeletonState extends State<ProductDetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final shimmerColor = baseColor.withAlpha(
          (_animation.value * 255).round(),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image carousel skeleton
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: AppConstants.space20),

              // Brand chip skeleton
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.space8),

              // Title skeleton
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Container(
                height: 24,
                width: 200,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.space16),

              // Price skeleton
              Container(
                height: 28,
                width: 140,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.space24),

              // Description skeleton
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Container(
                height: 14,
                width: 260,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
