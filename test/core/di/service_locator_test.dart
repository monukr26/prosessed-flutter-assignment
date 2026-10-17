import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/core/network/api_client.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  test(
    'initDependencies registers ApiClient, Dio, and FlutterSecureStorage',
    () async {
      await initDependencies();

      expect(sl.isRegistered<ApiClient>(), isTrue);
      expect(sl.isRegistered<Dio>(), isTrue);
      expect(sl.isRegistered<FlutterSecureStorage>(), isTrue);

      final apiClient = sl<ApiClient>();
      final dio = sl<Dio>();
      final storage = sl<FlutterSecureStorage>();

      expect(apiClient, isNotNull);
      expect(dio, isNotNull);
      expect(storage, isNotNull);
    },
  );
}
