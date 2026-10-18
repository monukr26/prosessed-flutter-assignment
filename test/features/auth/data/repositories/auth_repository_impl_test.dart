import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/models/login_response_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockApiClient mockApiClient;
  late AuthRepositoryImpl repository;

  const testUser = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emilys@dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  const testLoginResponse = LoginResponseModel(
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
    user: testUser,
  );

  setUpAll(() {
    registerFallbackValue(testUser);
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockApiClient = MockApiClient();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      apiClient: mockApiClient,
    );
  });

  group('login', () {
    test(
      'saves tokens, user and updates ApiClient before returning User on success',
      () async {
        when(
          () => mockRemoteDataSource.login(
            username: 'emilys',
            password: 'emilyspass',
          ),
        ).thenAnswer((_) async => testLoginResponse);

        when(
          () => mockLocalDataSource.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockLocalDataSource.saveUser(any()),
        ).thenAnswer((_) async {});

        when(() => mockApiClient.updateAuthToken(any())).thenReturn(null);

        final result = await repository.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testUser));
        verify(
          () => mockLocalDataSource.saveTokens(
            accessToken: 'test_access_token',
            refreshToken: 'test_refresh_token',
          ),
        ).called(1);
        verify(() => mockLocalDataSource.saveUser(testUser)).called(1);
        verify(
          () => mockApiClient.updateAuthToken('test_access_token'),
        ).called(1);
      },
    );

    test('returns AuthFailure on AuthException 400', () async {
      when(
        () => mockRemoteDataSource.login(username: 'emilys', password: 'wrong'),
      ).thenThrow(
        const AuthException('Invalid username or password', statusCode: 400),
      );

      final result = await repository.login(
        username: 'emilys',
        password: 'wrong',
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const AuthFailure('Invalid username or password', 400)),
      );
    });
  });

  group('getCurrentUser (session restoration)', () {
    test('fetches user from remote if token exists in local storage', () async {
      when(
        () => mockLocalDataSource.getAccessToken(),
      ).thenAnswer((_) async => 'stored_token');
      when(() => mockApiClient.updateAuthToken(any())).thenReturn(null);
      when(
        () => mockRemoteDataSource.getCurrentUser('stored_token'),
      ).thenAnswer((_) async => testUser);
      when(
        () => mockLocalDataSource.saveUser(testUser),
      ).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(testUser));
      verify(() => mockApiClient.updateAuthToken('stored_token')).called(1);
    });

    test(
      'clears tokens and returns AuthFailure when remote returns 401 session expired',
      () async {
        when(
          () => mockLocalDataSource.getAccessToken(),
        ).thenAnswer((_) async => 'expired_token');
        when(() => mockApiClient.updateAuthToken(any())).thenReturn(null);
        when(
          () => mockRemoteDataSource.getCurrentUser('expired_token'),
        ).thenThrow(
          const AuthException(
            'Session expired. Please sign in again.',
            statusCode: 401,
          ),
        );
        when(
          () => mockLocalDataSource.getRefreshToken(),
        ).thenAnswer((_) async => null);
        when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async {});

        final result = await repository.getCurrentUser();

        expect(result.isFailure, isTrue);
        verify(() => mockLocalDataSource.clearSession()).called(1);
        verify(() => mockApiClient.updateAuthToken(null)).called(1);
      },
    );
  });

  group('logout', () {
    test(
      'clears session from local storage and removes ApiClient header',
      () async {
        when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async {});
        when(() => mockApiClient.updateAuthToken(null)).thenReturn(null);

        final result = await repository.logout();

        expect(result.isSuccess, isTrue);
        verify(() => mockLocalDataSource.clearSession()).called(1);
        verify(() => mockApiClient.updateAuthToken(null)).called(1);
      },
    );
  });
}
