import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/repositories/checkout_repository.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  test(
    'initDependencies registers ApiClient, Dio, Storage, SharedPreferences and Repositories',
    () async {
      await initDependencies();

      expect(sl.isRegistered<ApiClient>(), isTrue);
      expect(sl.isRegistered<Dio>(), isTrue);
      expect(sl.isRegistered<FlutterSecureStorage>(), isTrue);
      expect(sl.isRegistered<SharedPreferences>(), isTrue);
      expect(sl.isRegistered<CartRepository>(), isTrue);
      expect(sl.isRegistered<CheckoutRepository>(), isTrue);

      final apiClient = sl<ApiClient>();
      final dio = sl<Dio>();
      final storage = sl<FlutterSecureStorage>();
      final prefs = sl<SharedPreferences>();

      expect(apiClient, isNotNull);
      expect(dio, isNotNull);
      expect(storage, isNotNull);
      expect(prefs, isNotNull);
    },
  );
}
