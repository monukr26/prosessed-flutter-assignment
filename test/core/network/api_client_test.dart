import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';

void main() {
  group('ApiClient', () {
    test('initializes with correct base URL and timeouts', () {
      final client = ApiClient();

      expect(client.dio.options.baseUrl, equals(ApiEndpoints.baseUrl));
      expect(
        client.dio.options.connectTimeout,
        equals(ApiEndpoints.connectTimeout),
      );
      expect(
        client.dio.options.receiveTimeout,
        equals(ApiEndpoints.receiveTimeout),
      );
      expect(
        client.dio.options.headers['Content-Type'],
        equals('application/json'),
      );
    });

    test('updateAuthToken sets and clears Authorization header', () {
      final client = ApiClient();

      client.updateAuthToken('sample_token_123');
      expect(
        client.dio.options.headers['Authorization'],
        equals('Bearer sample_token_123'),
      );

      client.updateAuthToken(null);
      expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
    });
  });
}
