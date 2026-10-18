import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late ProviderContainer container;

  const testUser = User(
    id: 1,
    username: 'emilys',
    email: 'emilys@dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();

    container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(
          () => AuthNotifier(
            loginUseCase: mockLoginUseCase,
            getCurrentUserUseCase: mockGetCurrentUserUseCase,
            logoutUseCase: mockLogoutUseCase,
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state should be AuthInitial', () {
    expect(container.read(authNotifierProvider), equals(const AuthInitial()));
  });

  group('checkAuthStatus', () {
    test('emits [AuthLoading, Authenticated] on valid session', () async {
      when(
        () => mockGetCurrentUserUseCase(),
      ).thenAnswer((_) async => const Result.success(testUser));

      final states = <AuthState>[];
      container.listen(
        authNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authNotifierProvider.notifier).checkAuthStatus();

      expect(states, [
        const AuthInitial(),
        const AuthLoading(),
        const Authenticated(testUser),
      ]);
    });

    test(
      'emits [AuthLoading, Unauthenticated] when no session exists',
      () async {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Result.failure(AuthFailure('No active session')),
        );

        final states = <AuthState>[];
        container.listen(
          authNotifierProvider,
          (previous, next) => states.add(next),
          fireImmediately: true,
        );

        await container.read(authNotifierProvider.notifier).checkAuthStatus();

        expect(states, [
          const AuthInitial(),
          const AuthLoading(),
          const Unauthenticated('No active session'),
        ]);
      },
    );
  });

  group('login', () {
    test(
      'emits [AuthLoading, Authenticated] on successful credentials',
      () async {
        when(
          () => mockLoginUseCase(username: 'emilys', password: 'emilyspass'),
        ).thenAnswer((_) async => const Result.success(testUser));

        final states = <AuthState>[];
        container.listen(
          authNotifierProvider,
          (previous, next) => states.add(next),
          fireImmediately: true,
        );

        final success = await container
            .read(authNotifierProvider.notifier)
            .login('emilys', 'emilyspass');

        expect(success, isTrue);
        expect(states, [
          const AuthInitial(),
          const AuthLoading(),
          const Authenticated(testUser),
        ]);
      },
    );

    test('emits [AuthLoading, AuthError] on invalid credentials', () async {
      when(
        () => mockLoginUseCase(username: 'emilys', password: 'wrongpassword'),
      ).thenAnswer(
        (_) async => const Result.failure(
          AuthFailure('Invalid username or password', 400),
        ),
      );

      final states = <AuthState>[];
      container.listen(
        authNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      final success = await container
          .read(authNotifierProvider.notifier)
          .login('emilys', 'wrongpassword');

      expect(success, isFalse);
      expect(states, [
        const AuthInitial(),
        const AuthLoading(),
        const AuthError('Invalid username or password'),
      ]);
    });
  });

  group('logout', () {
    test('emits [AuthLoading, Unauthenticated] on logout', () async {
      when(
        () => mockLogoutUseCase(),
      ).thenAnswer((_) async => const Result.success(null));

      final states = <AuthState>[];
      container.listen(
        authNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authNotifierProvider.notifier).logout();

      expect(states, [
        const AuthInitial(),
        const AuthLoading(),
        const Unauthenticated(),
      ]);
    });
  });
}
