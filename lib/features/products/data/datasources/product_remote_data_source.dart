import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/products/data/models/category_model.dart';
import 'package:shopsphere/features/products/data/models/paginated_products_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';

abstract class ProductRemoteDataSource {
  Future<PaginatedProductsModel> getProducts({
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  });

  Future<PaginatedProductsModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  });

  Future<PaginatedProductsModel> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  });

  Future<ProductModel> getProductDetails(int id);

  Future<List<CategoryModel>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;

  const ProductRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedProductsModel> getProducts({
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'skip': skip};

      if (sortOption != SortOption.none && sortOption.field != null) {
        queryParams['sortBy'] = sortOption.field;
        queryParams['order'] = sortOption.order ?? 'asc';
      }

      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return PaginatedProductsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Failed to load products with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedProductsModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'limit': limit,
        'skip': skip,
      };

      if (sortOption != SortOption.none && sortOption.field != null) {
        queryParams['sortBy'] = sortOption.field;
        queryParams['order'] = sortOption.order ?? 'asc';
      }

      final response = await _dio.get(
        ApiEndpoints.searchProducts,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return PaginatedProductsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Failed to search products with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedProductsModel> getProductsByCategory({
    required String categorySlug,
    int limit = 20,
    int skip = 0,
    SortOption sortOption = SortOption.none,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'skip': skip};

      if (sortOption != SortOption.none && sortOption.field != null) {
        queryParams['sortBy'] = sortOption.field;
        queryParams['order'] = sortOption.order ?? 'asc';
      }

      final response = await _dio.get(
        ApiEndpoints.productsByCategory(categorySlug),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return PaginatedProductsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Failed to fetch category products with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.productDetails(id));

      if (response.statusCode == 200 && response.data != null) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Failed to load product details with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Product not found', statusCode: 404);
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.categories);

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List<dynamic>;
        return list.map((item) => CategoryModel.fromDynamic(item)).toList();
      } else {
        throw ServerException(
          'Failed to load categories with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    final status = error.response?.statusCode;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'Connection timeout or network failure. Please check your internet connection.',
      );
    }

    final message =
        (error.response?.data is Map && error.response?.data['message'] != null)
        ? error.response?.data['message'] as String
        : (error.message ?? 'Server error occurred');

    return ServerException(message, statusCode: status);
  }
}
