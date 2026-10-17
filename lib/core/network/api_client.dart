import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';

/// Centralized API client configured with Dio.
///
/// Configures baseUrl, connection/receive timeouts, default headers,
/// and debug-only logging interceptor.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? customDio})
    : dio =
          customDio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: ApiEndpoints.connectTimeout,
              receiveTimeout: ApiEndpoints.receiveTimeout,
              sendTimeout: ApiEndpoints.sendTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Only attach logging in debug mode to prevent leaking tokens or payload in release builds
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (log) => debugPrint(log.toString()),
        ),
      );
    }
  }

  void updateAuthToken(String? token) {
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }
}
