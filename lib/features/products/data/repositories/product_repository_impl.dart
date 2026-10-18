import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  const ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<PaginatedProducts>> getProducts({
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) async {
    try {
      final response = await _remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
        sortOption: sortOption,
      );

      // Apply in-memory sort consistency
      final sortedProducts = sortOption != SortOption.none
          ? sortOption.apply(response.products)
          : response.products;

      return Result.success(
        PaginatedProducts(
          products: sortedProducts,
          total: response.total,
          skip: response.skip,
          limit: response.limit,
        ),
      );
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected error loading products: $e'),
      );
    }
  }

  @override
  Future<Result<PaginatedProducts>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) async {
    try {
      final response = await _remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
        sortOption: sortOption,
      );

      // Local sort fallback for search endpoints ensures search filters are never discarded
      final sortedProducts = sortOption != SortOption.none
          ? sortOption.apply(response.products)
          : response.products;

      return Result.success(
        PaginatedProducts(
          products: sortedProducts,
          total: response.total,
          skip: response.skip,
          limit: response.limit,
        ),
      );
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected error searching products: $e'),
      );
    }
  }

  @override
  Future<Result<PaginatedProducts>> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) async {
    try {
      final response = await _remoteDataSource.getProductsByCategory(
        categorySlug: categorySlug,
        limit: limit,
        skip: skip,
        sortOption: sortOption,
      );

      // In-memory sort fallback for category endpoint
      final sortedProducts = sortOption != SortOption.none
          ? sortOption.apply(response.products)
          : response.products;

      return Result.success(
        PaginatedProducts(
          products: sortedProducts,
          total: response.total,
          skip: response.skip,
          limit: response.limit,
        ),
      );
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected error loading category products: $e'),
      );
    }
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Result.success(categories);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected error loading categories: $e'),
      );
    }
  }
}
