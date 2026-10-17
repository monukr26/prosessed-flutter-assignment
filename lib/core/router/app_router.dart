import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/auth/presentation/splash_screen.dart';

/// Application route path constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String products = '/products';
  static const String productDetails = '/products/:id';
  static const String cart = '/cart';
  static const String profile = '/profile';
}

/// GoRouter instance provider managed via Riverpod.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
});
