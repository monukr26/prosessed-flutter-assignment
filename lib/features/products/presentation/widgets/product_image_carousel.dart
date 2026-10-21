import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';

/// Interactive image carousel with smooth page indicators and image cache support.
class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final String fallbackThumbnail;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.fallbackThumbnail,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<String> get _displayImages {
    if (widget.images.isNotEmpty) return widget.images;
    if (widget.fallbackThumbnail.isNotEmpty) {
      return [widget.fallbackThumbnail];
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = _displayImages;
    final isDark = theme.brightness == Brightness.dark;

    if (images.isEmpty) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.39),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 340,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(AppConstants.radius16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppConstants.space16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.39,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Page counter pill overlay (e.g. 1/4)
              if (images.length > 1)
                Positioned(
                  bottom: AppConstants.space12,
                  right: AppConstants.space12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Dots page indicator below
        if (images.length > 1) ...[
          const SizedBox(height: AppConstants.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.24,
                        ),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
