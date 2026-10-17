import 'package:equatable/equatable.dart';

/// Base Failure class in the domain layer.
///
/// Domain models and use cases communicate error states through typed [Failure]
/// objects without any dependency on Flutter or HTTP libraries.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'A server error occurred. Please try again later.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network and retry.',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failed. Please sign in again.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local cached data.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
