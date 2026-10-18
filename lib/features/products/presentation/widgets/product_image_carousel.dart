import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';

/// Interactive image carousel with page indicators and image cache support.
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

    if (images.isEmpty) {
      return Container(
        height: 320,
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    40,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    40,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Dots page indicator
        if (images.length > 1) ...[
          const SizedBox(height: AppConstants.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isSelected ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.onSurfaceVariant.withAlpha(70),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
