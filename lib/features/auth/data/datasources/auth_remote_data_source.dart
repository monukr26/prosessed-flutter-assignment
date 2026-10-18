import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password, 'expiresInMins': 30},
      );

      if (response.statusCode == 200 && response.data != null) {
        return LoginResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          'Failed to login with status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const AuthException(
          'Invalid username or password',
          statusCode: 400,
        );
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.me,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Failed to fetch user profile with status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(
          'Session expired. Please sign in again.',
          statusCode: 401,
        );
      }
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
