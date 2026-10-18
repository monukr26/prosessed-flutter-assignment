import 'package:shopsphere/core/error/failures.dart';

/// Type-safe Result pattern using Dart 3 sealed classes.
///
/// Encapsulates either a successful value of type [T] or a domain [Failure].
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
    Success(data: final d) => d,
    Error() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Error(failure: final f) => f,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(data: final d) => success(d),
      Error(failure: final f) => failure(f),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
