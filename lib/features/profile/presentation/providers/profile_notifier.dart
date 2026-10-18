import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/di/service_locator.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';
import 'package:shopsphere/features/profile/presentation/providers/profile_state.dart';

/// Riverpod Notifier managing profile fetching, retry states, session expiry,
/// and coordinating secure user logout.
class ProfileNotifier extends Notifier<ProfileState> {
  final GetCurrentUserUseCase? _injectedGetCurrentUserUseCase;
  final LogoutUseCase? _injectedLogoutUseCase;

  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  ProfileNotifier({
    GetCurrentUserUseCase? getCurrentUserUseCase,
    LogoutUseCase? logoutUseCase,
  }) : _injectedGetCurrentUserUseCase = getCurrentUserUseCase,
       _injectedLogoutUseCase = logoutUseCase;

  @override
  ProfileState build() {
    _getCurrentUserUseCase =
        _injectedGetCurrentUserUseCase ?? sl<GetCurrentUserUseCase>();
    _logoutUseCase = _injectedLogoutUseCase ?? sl<LogoutUseCase>();

    // Initial check from active in-memory session if available
    final authState = ref.read(authNotifierProvider);
    final currentUser = authState is Authenticated ? authState.user : null;

    Future.microtask(loadProfile);

    return currentUser != null
        ? ProfileState.success(currentUser)
        : ProfileState.initial();
  }

  /// Fetches the authenticated user profile from GET /auth/me with Bearer token.
  ///
  /// Handles 401 session expiry and network failures with retry support.
  Future<void> loadProfile() async {
    state = ProfileState.loading(currentUser: state.user);

    final result = await _getCurrentUserUseCase();

    result.when(
      success: (user) {
        state = ProfileState.success(user);
      },
      failure: (failure) {
        if (failure is AuthFailure && failure.statusCode == 401) {
          state = ProfileState.sessionExpired(failure.message);
          // Notify global auth state to redirect to login with explanatory message
          ref
              .read(authNotifierProvider.notifier)
              .handleSessionExpired(failure.message);
        } else {
          state = ProfileState.error(failure.message, currentUser: state.user);
        }
      },
    );
  }

  /// Securely logs out the user, clears credentials, and returns to login.
  Future<void> logout() async {
    if (state.isLoggingOut) return;

    state = state.copyWith(isLoggingOut: true);
    try {
      await _logoutUseCase();
      ref
          .read(authNotifierProvider.notifier)
          .handleSessionExpired('You have been logged out successfully.');
    } finally {
      state = state.copyWith(isLoggingOut: false);
    }
  }
}

/// Global provider for ProfileNotifier.
final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
