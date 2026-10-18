import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _accessTokenKey = 'shopsphere_access_token';
  static const String _refreshTokenKey = 'shopsphere_refresh_token';
  static const String _userKey = 'shopsphere_cached_user';

  final FlutterSecureStorage _storage;

  const AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException('Failed to securely save auth tokens: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw CacheException('Failed to read access token from storage: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to read refresh token from storage: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw CacheException('Failed to save user profile: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final raw = await _storage.read(key: _userKey);
      if (raw == null || raw.isEmpty) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to read cached user: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      throw CacheException('Failed to clear secure session: $e');
    }
  }
}
