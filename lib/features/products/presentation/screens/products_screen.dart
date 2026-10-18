import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/core/widgets/empty_view.dart';
import 'package:shopsphere/core/widgets/error_view.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_badge_icon.dart';
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial fetch on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productCatalogNotifierProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger load more when 250px from bottom
    if (currentScroll >= maxScroll - 250) {
      ref.read(productCatalogNotifierProvider.notifier).loadMore();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(productCatalogNotifierProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'ShopSphere',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          // Live Cart Action with Badge
          const CartBadgeIcon(),
          // Logout Action
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.space16,
              AppConstants.space8,
              AppConstants.space16,
              AppConstants.space8,
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
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: _clearSearch,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space16,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.space8),

                // Sort Action Button
                IconButton.filledTonal(
                  tooltip: 'Sort: ${catalogState.sortOption.label}',
                  icon: const Icon(Icons.sort_rounded),
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
                onRefresh: () =>
                    ref.read(productCatalogNotifierProvider.notifier).refresh(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppConstants.space16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: AppConstants.space12,
                          mainAxisSpacing: AppConstants.space12,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : (!catalogState.hasMore &&
                                    catalogState.products.isNotEmpty)
                              ? Text(
                                  'All ${catalogState.total} products loaded',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : const SizedBox.shrink(),
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
    );
  }
}
