/// Base exception for application-level errors.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() =>
      'AppException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Thrown when remote API responds with non-2xx status code.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Thrown on connectivity, socket or DNS resolution issues.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}

/// Thrown on 401/403 or authentication session expirations.
class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode});
}

/// Thrown on 404 Not Found responses.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode = 404});
}

/// Thrown when local persistence / cache operations fail.
class CacheException extends AppException {
  const CacheException(super.message, {super.statusCode});
}
