import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
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
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    phone: '+81 965-431-3024',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockApiClient = MockApiClient();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      apiClient: mockApiClient,
    );

    registerFallbackValue(testUser);
  });

  group('Profile Repository (AuthRepositoryImpl.getCurrentUser & logout)', () {
    test(
      'successfully fetches and caches user profile on valid session',
      () async {
        when(
          () => mockLocalDataSource.getAccessToken(),
        ).thenAnswer((_) async => 'valid_token');
        when(
          () => mockApiClient.updateAuthToken('valid_token'),
        ).thenReturn(null);
        when(
          () => mockRemoteDataSource.getCurrentUser('valid_token'),
        ).thenAnswer((_) async => testUser);
        when(
          () => mockLocalDataSource.saveUser(testUser),
        ).thenAnswer((_) async {});

        final result = await repository.getCurrentUser();

        expect(result.isSuccess, true);
        expect(result.dataOrNull, testUser);
        expect(result.dataOrNull?.phone, '+81 965-431-3024');
        verify(() => mockLocalDataSource.saveUser(testUser)).called(1);
        verify(() => mockApiClient.updateAuthToken('valid_token')).called(1);
      },
    );

    test(
      'on HTTP 401, attempts token refresh and successfully recovers session',
      () async {
        when(
          () => mockLocalDataSource.getAccessToken(),
        ).thenAnswer((_) async => 'expired_token');
        when(() => mockApiClient.updateAuthToken(any())).thenReturn(null);

        // First call fails with 401
        when(
          () => mockRemoteDataSource.getCurrentUser('expired_token'),
        ).thenThrow(const AuthException('Session expired', statusCode: 401));

        // Refresh token is available
        when(
          () => mockLocalDataSource.getRefreshToken(),
        ).thenAnswer((_) async => 'valid_refresh_token');
        when(
          () => mockRemoteDataSource.refreshSession('valid_refresh_token'),
        ).thenAnswer(
          (_) async => (
            accessToken: 'new_access_token',
            refreshToken: 'new_refresh_token',
          ),
        );
        when(
          () => mockLocalDataSource.saveTokens(
            accessToken: 'new_access_token',
            refreshToken: 'new_refresh_token',
          ),
        ).thenAnswer((_) async {});

        // Retry with new token succeeds
        when(
          () => mockRemoteDataSource.getCurrentUser('new_access_token'),
        ).thenAnswer((_) async => testUser);
        when(
          () => mockLocalDataSource.saveUser(testUser),
        ).thenAnswer((_) async {});

        final result = await repository.getCurrentUser();

        expect(result.isSuccess, true);
        expect(result.dataOrNull, testUser);
        verify(
          () => mockRemoteDataSource.refreshSession('valid_refresh_token'),
        ).called(1);
        verify(
          () => mockApiClient.updateAuthToken('new_access_token'),
        ).called(1);
      },
    );

    test(
      'on HTTP 401 when refresh fails, clears session and returns AuthFailure',
      () async {
        when(
          () => mockLocalDataSource.getAccessToken(),
        ).thenAnswer((_) async => 'expired_token');
        when(() => mockApiClient.updateAuthToken(any())).thenReturn(null);

        when(
          () => mockRemoteDataSource.getCurrentUser('expired_token'),
        ).thenThrow(const AuthException('Session expired', statusCode: 401));

        // Refresh token fails
        when(
          () => mockLocalDataSource.getRefreshToken(),
        ).thenAnswer((_) async => 'invalid_refresh_token');
        when(
          () => mockRemoteDataSource.refreshSession('invalid_refresh_token'),
        ).thenThrow(const AuthException('Refresh expired', statusCode: 401));

        when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async {});

        final result = await repository.getCurrentUser();

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<AuthFailure>());
        expect(result.failureOrNull?.statusCode, 401);
        verify(() => mockLocalDataSource.clearSession()).called(1);
        verify(() => mockApiClient.updateAuthToken(null)).called(1);
      },
    );

    test(
      'returns NetworkFailure when remote fails and no cached user exists',
      () async {
        when(
          () => mockLocalDataSource.getAccessToken(),
        ).thenAnswer((_) async => 'token');
        when(() => mockApiClient.updateAuthToken('token')).thenReturn(null);
        when(
          () => mockRemoteDataSource.getCurrentUser('token'),
        ).thenThrow(const NetworkException('No internet'));
        when(
          () => mockLocalDataSource.getCachedUser(),
        ).thenAnswer((_) async => null);

        final result = await repository.getCurrentUser();

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<NetworkFailure>());
      },
    );

    test(
      'returns ServerFailure when remote throws 500 ServerException',
      () async {
        when(
          () => mockLocalDataSource.getAccessToken(),
        ).thenAnswer((_) async => 'token');
        when(() => mockApiClient.updateAuthToken('token')).thenReturn(null);
        when(() => mockRemoteDataSource.getCurrentUser('token')).thenThrow(
          const ServerException('Internal Server Error', statusCode: 500),
        );

        final result = await repository.getCurrentUser();

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<ServerFailure>());
        expect(result.failureOrNull?.statusCode, 500);
      },
    );

    test(
      'logout clears credentials from storage and removes ApiClient header',
      () async {
        when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async {});
        when(() => mockApiClient.updateAuthToken(null)).thenReturn(null);

        final result = await repository.logout();

        expect(result.isSuccess, true);
        verify(() => mockLocalDataSource.clearSession()).called(1);
        verify(() => mockApiClient.updateAuthToken(null)).called(1);
      },
    );
  });
}
