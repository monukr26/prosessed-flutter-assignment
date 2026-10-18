import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';

/// Contract for Product Repository in the domain layer.
abstract class ProductRepository {
  /// Fetches a paginated list of products from the catalogue.
  Future<Result<PaginatedProducts>> getProducts({
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  });

  /// Searches products matching [query] with pagination.
  Future<Result<PaginatedProducts>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  });

  /// Fetches products belonging to [categorySlug] with pagination.
  Future<Result<PaginatedProducts>> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  });

  /// Retrieves list of product categories.
  Future<Result<List<Category>>> getCategories();
}
