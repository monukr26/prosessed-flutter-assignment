import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';
import 'package:shopsphere/features/profile/presentation/providers/profile_notifier.dart';
import 'package:shopsphere/features/profile/presentation/providers/profile_state.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  const testUser = User(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    phone: '+81 965-431-3024',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
  });

  ProviderContainer createContainer({
    AuthState initialAuthState = const Authenticated(testUser),
  }) {
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(
          () => _MockAuthNotifier(initialAuthState),
        ),
        profileNotifierProvider.overrideWith(
          () => ProfileNotifier(
            getCurrentUserUseCase: mockGetCurrentUserUseCase,
            logoutUseCase: mockLogoutUseCase,
          ),
        ),
      ],
    );

    addTearDown(container.dispose);
    return container;
  }

  group('ProfileNotifier', () {
    test('initializes with active user and loads profile on build', () async {
      when(
        () => mockGetCurrentUserUseCase(),
      ).thenAnswer((_) async => const Result.success(testUser));

      final container = createContainer();
      await container.read(profileNotifierProvider.notifier).loadProfile();

      final state = container.read(profileNotifierProvider);
      expect(state.status, ProfileStatus.success);
      expect(state.user, testUser);
      expect(state.user?.phone, '+81 965-431-3024');
    });

    test('emits error state on network or server failure', () async {
      when(() => mockGetCurrentUserUseCase()).thenAnswer(
        (_) async =>
            const Result.failure(NetworkFailure('No internet connection')),
      );

      final container = createContainer();
      await container.read(profileNotifierProvider.notifier).loadProfile();

      final state = container.read(profileNotifierProvider);
      expect(state.status, ProfileStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });

    test(
      'emits sessionExpired and triggers auth redirection on HTTP 401',
      () async {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Result.failure(
            AuthFailure('Session expired. Please sign in again.', 401),
          ),
        );

        final container = createContainer();
        await container.read(profileNotifierProvider.notifier).loadProfile();

        final state = container.read(profileNotifierProvider);
        expect(state.status, ProfileStatus.sessionExpired);
        expect(state.errorMessage, 'Session expired. Please sign in again.');

        // Check global auth state is set to Unauthenticated
        final authState = container.read(authNotifierProvider);
        expect(authState, isA<Unauthenticated>());
        expect(
          (authState as Unauthenticated).message,
          contains('Session expired'),
        );
      },
    );

    test('logout calls logout use case and clears authentication', () async {
      when(
        () => mockGetCurrentUserUseCase(),
      ).thenAnswer((_) async => const Result.success(testUser));
      when(
        () => mockLogoutUseCase(),
      ).thenAnswer((_) async => const Result.success(null));

      final container = createContainer();
      await container.read(profileNotifierProvider.notifier).logout();

      verify(() => mockLogoutUseCase()).called(1);
      final authState = container.read(authNotifierProvider);
      expect(authState, isA<Unauthenticated>());
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  final AuthState _initial;
  _MockAuthNotifier(this._initial);

  @override
  AuthState build() => _initial;

  @override
  void handleSessionExpired([
    String message = 'Session expired. Please sign in again.',
  ]) {
    state = Unauthenticated(message);
  }

  @override
  Future<void> logout() async {
    state = const Unauthenticated('You have been logged out successfully.');
  }
}
