import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

/// Explicit authentication states for ShopSphere.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state before checking stored session.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Active loading state during session restoration or login request.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with active [user] session.
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state with optional explanatory message (e.g. after logout or expired session).
class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Error state containing a user-friendly failure [message].
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
