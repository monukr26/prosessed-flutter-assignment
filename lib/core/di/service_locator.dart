import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shopsphere/core/network/api_client.dart';

/// Global service locator instance using get_it.
final GetIt sl = GetIt.instance;

/// Initialize foundational dependencies and singletons.
Future<void> initDependencies() async {
  // Core Network
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

  // Future feature registrations (Auth, Products, Cart, Profile) will be hooked here.
}
