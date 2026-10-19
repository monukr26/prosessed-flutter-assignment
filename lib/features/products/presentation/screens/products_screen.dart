import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/core/widgets/empty_view.dart';
import 'package:shopsphere/core/widgets/error_view.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_notifier.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_state.dart';
import 'package:shopsphere/features/products/presentation/widgets/category_chips_bar.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_grid_skeleton.dart';
import 'package:shopsphere/features/products/presentation/widgets/sort_filter_sheet.dart';

/// Main Product Catalogue Screen with responsive grid, debounce search, categories & pagination.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Trigger pagination threshold at 200px before end
      if (maxScroll - currentScroll <= 200) {
        ref.read(productCatalogNotifierProvider.notifier).loadMore();
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      ref.read(productCatalogNotifierProvider.notifier).setSearchQuery(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    ref.read(productCatalogNotifierProvider.notifier).setSearchQuery('');
  }

  int _calculateCrossAxisCount(double width) {
    if (width < AppConstants.compactBreakpoint) {
      return 2;
    } else if (width <= AppConstants.mediumBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  double _calculateAspectRatio(double width) {
    if (width < AppConstants.compactBreakpoint) {
      return 0.65; // Accommodates 1.3x text scaling safely
    } else if (width <= AppConstants.mediumBreakpoint) {
      return 0.69;
    } else {
      return 0.72;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(productCatalogNotifierProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);
    final childAspectRatio = _calculateAspectRatio(screenWidth);
    final isExpanded = screenWidth > AppConstants.mediumBreakpoint;

    // Listen to load more errors without disrupting grid
    ref.listen<ProductCatalogState>(productCatalogNotifierProvider, (
      previous,
      next,
    ) {
      if (next.loadMoreErrorMessage != null &&
          previous?.loadMoreErrorMessage != next.loadMoreErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.loadMoreErrorMessage!),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                ref.read(productCatalogNotifierProvider.notifier).loadMore();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: AppConstants.space16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppConstants.space8),
            Text(
              'ShopSphere',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isExpanded ? 1200 : double.infinity,
          ),
          child: Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.space16,
                  AppConstants.space8,
                  AppConstants.space16,
                  AppConstants.space12,
                ),
                child: Row(
                  children: [
                    // Search Input Field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search products, brands...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.space16,
                            vertical: 11,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),

                    // Sort Action Button
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radius12,
                        ),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: IconButton(
                        tooltip: 'Sort: ${catalogState.sortOption.label}',
                        constraints: const BoxConstraints(
                          minWidth: AppConstants.minTouchTarget,
                          minHeight: AppConstants.minTouchTarget,
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 20),
                        onPressed: () {
                          SortFilterSheet.show(
                            context,
                            currentSort: catalogState.sortOption,
                            onSortSelected: (option) {
                              ref
                                  .read(productCatalogNotifierProvider.notifier)
                                  .setSortOption(option);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Horizontal Bar
              const CategoryChipsBar(),
              const SizedBox(height: AppConstants.space8),

              // Products Content Area
              Expanded(
                child: switch (catalogState.status) {
                  ProductStatus.initial || ProductStatus.loading =>
                    ProductGridSkeleton(crossAxisCount: crossAxisCount),
                  ProductStatus.error => ErrorView(
                    message:
                        catalogState.errorMessage ??
                        'Failed to load products. Please try again.',
                    onRetry: () {
                      ref
                          .read(productCatalogNotifierProvider.notifier)
                          .loadInitial();
                    },
                  ),
                  ProductStatus.empty => EmptyView(
                    title: 'No products found',
                    message: catalogState.hasActiveFilter
                        ? 'No items match your active search or category filters.'
                        : 'Catalogue is currently empty.',
                    icon: Icons.search_off_rounded,
                    action: catalogState.hasActiveFilter
                        ? FilledButton.icon(
                            onPressed: () {
                              _clearSearch();
                              ref
                                  .read(productCatalogNotifierProvider.notifier)
                                  .selectCategory(null);
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reset Filters'),
                          )
                        : null,
                  ),
                  ProductStatus.success ||
                  ProductStatus.loadingMore => RefreshIndicator(
                    onRefresh: () => ref
                        .read(productCatalogNotifierProvider.notifier)
                        .refresh(),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(AppConstants.space16),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: AppConstants.space12,
                                  mainAxisSpacing: AppConstants.space12,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = catalogState.products[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  context.push('/products/${product.id}');
                                },
                              );
                            }, childCount: catalogState.products.length),
                          ),
                        ),

                        // Footer Loading Indicator or End of List Indicator
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.space16,
                            ),
                            child: Center(
                              child: catalogState.isLoadingMore
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                      ),
                                    )
                                  : catalogState.hasMore
                                  ? const SizedBox.shrink()
                                  : Text(
                                      'You\'ve viewed all ${catalogState.products.length} products',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
