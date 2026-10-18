import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';

/// Explicit status of the product catalogue state.
enum ProductStatus { initial, loading, success, loadingMore, empty, error }

/// Immutable state representing the catalogue, search, filtering and pagination.
class ProductCatalogState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;
  final bool hasMore;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final Category? selectedCategory;
  final String searchQuery;
  final SortOption sortOption;

  const ProductCatalogState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    this.hasMore = false,
    this.errorMessage,
    this.loadMoreErrorMessage,
    this.selectedCategory,
    this.searchQuery = '',
    this.sortOption = SortOption.none,
  });

  bool get isInitialLoading => status == ProductStatus.loading;
  bool get isLoadingMore => status == ProductStatus.loadingMore;
  bool get hasActiveFilter =>
      selectedCategory != null || searchQuery.isNotEmpty;

  ProductCatalogState copyWith({
    ProductStatus? status,
    List<Product>? products,
    int? total,
    int? skip,
    int? limit,
    bool? hasMore,
    String? errorMessage,
    String? loadMoreErrorMessage,
    Category? Function()? selectedCategory,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return ProductCatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      loadMoreErrorMessage: loadMoreErrorMessage,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    total,
    skip,
    limit,
    hasMore,
    errorMessage,
    loadMoreErrorMessage,
    selectedCategory,
    searchQuery,
    sortOption,
  ];
}
