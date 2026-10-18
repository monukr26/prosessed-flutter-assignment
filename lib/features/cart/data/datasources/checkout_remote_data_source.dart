import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/cart/data/models/checkout_order_model.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';

/// Contract for checkout operations interacting with DummyJSON.
abstract class CheckoutRemoteDataSource {
  Future<CheckoutOrderModel> checkout({
    required int userId,
    required List<CartItem> items,
  });
}

/// Dio implementation of [CheckoutRemoteDataSource].
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final Dio _dio;

  const CheckoutRemoteDataSourceImpl(this._dio);

  @override
  Future<CheckoutOrderModel> checkout({
    required int userId,
    required List<CartItem> items,
  }) async {
    try {
      final payload = {
        'userId': userId,
        'products': items
            .map((item) => {'id': item.product.id, 'quantity': item.quantity})
            .toList(),
      };

      final response = await _dio.post(ApiEndpoints.addCart, data: payload);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return CheckoutOrderModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Failed to complete checkout with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error during checkout: $e');
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
        : (error.message ?? 'Server error occurred during checkout');

    return ServerException(message, statusCode: status);
  }
}
