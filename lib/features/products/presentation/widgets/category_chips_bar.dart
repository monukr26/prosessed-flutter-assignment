import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/products/presentation/providers/categories_notifier.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_notifier.dart';

/// Horizontally scrollable category filter chips with an 'All' option.
class CategoryChipsBar extends ConsumerWidget {
  const CategoryChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final catalogState = ref.watch(productCatalogNotifierProvider);
    final selectedCategory = catalogState.selectedCategory;

    return SizedBox(
      height: 48,
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
              if (index == 0) {
                final isAllSelected = selectedCategory == null;
                return FilterChip(
                  label: const Text('All'),
                  selected: isAllSelected,
                  onSelected: (_) {
                    ref
                        .read(productCatalogNotifierProvider.notifier)
                        .selectCategory(null);
                  },
                );
              }

              final category = categories[index - 1];
              final isSelected = selectedCategory?.slug == category.slug;

              return FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(productCatalogNotifierProvider.notifier)
                      .selectCategory(category);
                },
              );
            },
          );
        },
      ),
    );
  }
}
