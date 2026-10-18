import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/auth/presentation/login_screen.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';
import 'package:shopsphere/features/auth/presentation/splash_screen.dart';
import 'package:shopsphere/features/products/presentation/screens/product_details_screen.dart';
import 'package:shopsphere/features/products/presentation/screens/products_screen.dart';

/// Application route path constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetails = '/products/:id';
  static const String cart = '/cart';
  static const String profile = '/profile';
}

/// Reactive notifier bridging Riverpod auth state with GoRouter refresh and redirection.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final location = state.matchedLocation;
    final isGoingToLogin = location == AppRoutes.login;
    final isGoingToSplash = location == AppRoutes.splash;

    // While session check is in progress on splash, do not redirect
    if (authState is AuthInitial ||
        (authState is AuthLoading && isGoingToSplash)) {
      return null;
    }

    final isAuthenticated = authState is Authenticated;

    if (!isAuthenticated) {
      return isGoingToLogin ? null : AppRoutes.login;
    }

    // Authenticated users on splash or login are forwarded to Home catalogue
    if (isGoingToLogin || isGoingToSplash) {
      return AppRoutes.home;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// GoRouter instance provider with declarative redirect based on AuthState.
final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: 'productDetails',
        builder: (context, state) {
          final idParam = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idParam) ?? 0;
          return ProductDetailsScreen(productId: id);
        },
      ),
    ],
  );
});
