import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/products/presentation/providers/categories_notifier.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_notifier.dart';

/// Horizontally scrollable category filter chips with an 'All' option and smooth pill aesthetic.
class CategoryChipsBar extends ConsumerWidget {
  const CategoryChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final catalogState = ref.watch(productCatalogNotifierProvider);
    final selectedCategory = catalogState.selectedCategory;

    return SizedBox(
      height: 44,
      child: categoriesAsync.when(
        loading: () => const Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, stackTrace) => const SizedBox.shrink(),
        data: (categories) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space16,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppConstants.space8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isSelected = isAll
                  ? selectedCategory == null
                  : selectedCategory?.slug == categories[index - 1].slug;
              final label = isAll ? 'All Products' : categories[index - 1].name;

              return ActionChip(
                label: Text(label),
                backgroundColor: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.surface,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                onPressed: () {
                  if (isAll) {
                    ref
                        .read(productCatalogNotifierProvider.notifier)
                        .selectCategory(null);
                  } else {
                    ref
                        .read(productCatalogNotifierProvider.notifier)
                        .selectCategory(categories[index - 1]);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
