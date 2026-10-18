import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';

/// Riverpod Notifier managing authentication flow and session state.
class AuthNotifier extends Notifier<AuthState> {
  final LoginUseCase? _injectedLoginUseCase;
  final GetCurrentUserUseCase? _injectedGetCurrentUserUseCase;
  final LogoutUseCase? _injectedLogoutUseCase;

  late final LoginUseCase _loginUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    LoginUseCase? loginUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
    LogoutUseCase? logoutUseCase,
  }) : _injectedLoginUseCase = loginUseCase,
       _injectedGetCurrentUserUseCase = getCurrentUserUseCase,
       _injectedLogoutUseCase = logoutUseCase;

  @override
  AuthState build() {
    _loginUseCase = _injectedLoginUseCase ?? sl<LoginUseCase>();
    _getCurrentUserUseCase =
        _injectedGetCurrentUserUseCase ?? sl<GetCurrentUserUseCase>();
    _logoutUseCase = _injectedLogoutUseCase ?? sl<LogoutUseCase>();
    return const AuthInitial();
  }

  /// Checks for stored session and validates active token against GET /auth/me.
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final result = await _getCurrentUserUseCase();

    result.when(
      success: (user) {
        state = Authenticated(user);
      },
      failure: (failure) {
        state = Unauthenticated(failure.message);
      },
    );
  }

  /// Authenticates with credentials. Prevents duplicate concurrent calls.
  Future<bool> login(String username, String password) async {
    if (state is AuthLoading) return false;

    state = const AuthLoading();
    final result = await _loginUseCase(
      username: username.trim(),
      password: password,
    );

    return result.when(
      success: (user) {
        state = Authenticated(user);
        return true;
      },
      failure: (failure) {
        state = AuthError(failure.message);
        return false;
      },
    );
  }

  /// Securely logs out user and clears tokens.
  Future<void> logout() async {
    if (state is AuthLoading) return;
    state = const AuthLoading();
    await _logoutUseCase();
    state = const Unauthenticated();
  }

  /// Sets state to unauthenticated with explanatory session-expired message.
  void handleSessionExpired([
    String message = 'Your session has expired. Please sign in again.',
  ]) {
    state = Unauthenticated(message);
  }

  /// Clears any transient login error.
  void clearError() {
    if (state is AuthError) {
      state = const Unauthenticated();
    }
  }
}

/// Global provider for AuthNotifier using GetIt injected use cases.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
