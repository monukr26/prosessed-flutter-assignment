import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopsphere/features/products/presentation/providers/product_catalog_state.dart';

/// Riverpod Notifier managing product catalogue, search, filters, pagination and sorting.
class ProductCatalogNotifier extends Notifier<ProductCatalogState> {
  final GetProductsUseCase? _injectedGetProductsUseCase;
  final SearchProductsUseCase? _injectedSearchProductsUseCase;
  final GetProductsByCategoryUseCase? _injectedGetProductsByCategoryUseCase;

  late final GetProductsUseCase _getProductsUseCase;
  late final SearchProductsUseCase _searchProductsUseCase;
  late final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;

  int _currentRequestId = 0;

  ProductCatalogNotifier({
    GetProductsUseCase? getProductsUseCase,
    SearchProductsUseCase? searchProductsUseCase,
    GetProductsByCategoryUseCase? getProductsByCategoryUseCase,
  }) : _injectedGetProductsUseCase = getProductsUseCase,
       _injectedSearchProductsUseCase = searchProductsUseCase,
       _injectedGetProductsByCategoryUseCase = getProductsByCategoryUseCase;

  @override
  ProductCatalogState build() {
    _getProductsUseCase =
        _injectedGetProductsUseCase ?? sl<GetProductsUseCase>();
    _searchProductsUseCase =
        _injectedSearchProductsUseCase ?? sl<SearchProductsUseCase>();
    _getProductsByCategoryUseCase =
        _injectedGetProductsByCategoryUseCase ??
        sl<GetProductsByCategoryUseCase>();

    return const ProductCatalogState();
  }

  /// Initial load or filter change reset.
  Future<void> loadInitial() async {
    final requestId = ++_currentRequestId;
    state = state.copyWith(
      status: ProductStatus.loading,
      errorMessage: null,
      loadMoreErrorMessage: null,
      skip: 0,
    );

    final Result<PaginatedProducts> result;

    if (state.searchQuery.isNotEmpty) {
      result = await _searchProductsUseCase(
        query: state.searchQuery,
        limit: state.limit,
        skip: 0,
        sortOption: state.sortOption,
      );
    } else if (state.selectedCategory != null) {
      result = await _getProductsByCategoryUseCase(
        categorySlug: state.selectedCategory!.slug,
        limit: state.limit,
        skip: 0,
        sortOption: state.sortOption,
      );
    } else {
      result = await _getProductsUseCase(
        limit: state.limit,
        skip: 0,
        sortOption: state.sortOption,
      );
    }

    // Guard against stale asynchronous responses
    if (requestId != _currentRequestId) return;

    result.when(
      success: (data) {
        state = state.copyWith(
          status: data.products.isEmpty
              ? ProductStatus.empty
              : ProductStatus.success,
          products: data.products,
          total: data.total,
          skip: data.skip,
          hasMore: data.hasMore,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Loads next page of products without discarding already displayed items.
  Future<void> loadMore() async {
    // Prevent duplicate or redundant pagination calls
    if (state.isLoadingMore || state.isInitialLoading || !state.hasMore) return;

    state = state.copyWith(
      status: ProductStatus.loadingMore,
      loadMoreErrorMessage: null,
    );

    final nextSkip = state.products.length;
    final Result<PaginatedProducts> result;

    if (state.searchQuery.isNotEmpty) {
      result = await _searchProductsUseCase(
        query: state.searchQuery,
        limit: state.limit,
        skip: nextSkip,
        sortOption: state.sortOption,
      );
    } else if (state.selectedCategory != null) {
      result = await _getProductsByCategoryUseCase(
        categorySlug: state.selectedCategory!.slug,
        limit: state.limit,
        skip: nextSkip,
        sortOption: state.sortOption,
      );
    } else {
      result = await _getProductsUseCase(
        limit: state.limit,
        skip: nextSkip,
        sortOption: state.sortOption,
      );
    }

    result.when(
      success: (data) {
        final combined = [...state.products, ...data.products];
        // Maintain consistent sorting across paginated results
        final sorted = state.sortOption != SortOption.none
            ? state.sortOption.apply(combined)
            : combined;

        state = state.copyWith(
          status: ProductStatus.success,
          products: sorted,
          total: data.total,
          skip: data.skip,
          hasMore: (combined.length) < data.total,
        );
      },
      failure: (failure) {
        // Retain existing products upon load-more network error
        state = state.copyWith(
          status: ProductStatus.success,
          loadMoreErrorMessage: failure.message,
        );
      },
    );
  }

  /// Sets or clears active category filter. Clears search query.
  void selectCategory(Category? category) {
    if (state.selectedCategory?.slug == category?.slug &&
        state.searchQuery.isEmpty) {
      return;
    }

    state = state.copyWith(selectedCategory: () => category, searchQuery: '');

    loadInitial();
  }

  /// Updates search query with debounce caller. Clears selected category.
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (state.searchQuery == trimmed && state.selectedCategory == null) return;

    state = state.copyWith(searchQuery: trimmed, selectedCategory: () => null);

    loadInitial();
  }

  /// Updates sort option and applies sorting.
  void setSortOption(SortOption option) {
    if (state.sortOption == option) return;

    final sortedProducts = option.apply(state.products);
    state = state.copyWith(sortOption: option, products: sortedProducts);
  }

  /// Pull-to-refresh handler.
  Future<void> refresh() async {
    await loadInitial();
  }
}

/// Global provider for ProductCatalogNotifier.
final productCatalogNotifierProvider =
    NotifierProvider<ProductCatalogNotifier, ProductCatalogState>(
      ProductCatalogNotifier.new,
    );
