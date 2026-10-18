import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/utils/result.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final ApiClient _apiClient;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required ApiClient apiClient,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _apiClient = apiClient;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final loginResponse = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      // Persist access & refresh tokens securely
      await _localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      // Persist cached user profile
      await _localDataSource.saveUser(loginResponse.user);

      // Configure ApiClient header for subsequent requests
      _apiClient.updateAuthToken(loginResponse.accessToken);

      return Result.success(loginResponse.user);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected error during login: $e'),
      );
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final token = await _localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return const Result.failure(AuthFailure('No active session found'));
      }

      // Update ApiClient token
      _apiClient.updateAuthToken(token);

      final user = await _remoteDataSource.getCurrentUser(token);
      await _localDataSource.saveUser(user);

      return Result.success(user);
    } on AuthException catch (e) {
      // Clear invalid session tokens
      await _localDataSource.clearSession();
      _apiClient.updateAuthToken(null);
      return Result.failure(AuthFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      // If offline, check if we have a cached user profile
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Result.success(cachedUser);
      }
      return Result.failure(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(
        UnknownFailure('Failed to validate active session: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> hasSession() async {
    try {
      final token = await _localDataSource.getAccessToken();
      return Result.success(token != null && token.isNotEmpty);
    } catch (e) {
      return const Result.success(false);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _localDataSource.clearSession();
      _apiClient.updateAuthToken(null);
      return const Result.success(null);
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure('Failed to logout: $e'));
    }
  }
}
