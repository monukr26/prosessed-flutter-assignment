import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

enum ProfileStatus { initial, loading, success, error, sessionExpired }

/// State model representing the user profile view, including loading,
/// success, error, session-expired, and logout transitions.
class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoggingOut;

  const ProfileState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoggingOut = false,
  });

  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  factory ProfileState.loading({User? currentUser}) {
    return ProfileState(status: ProfileStatus.loading, user: currentUser);
  }

  factory ProfileState.success(User user) {
    return ProfileState(status: ProfileStatus.success, user: user);
  }

  factory ProfileState.error(String message, {User? currentUser}) {
    return ProfileState(
      status: ProfileStatus.error,
      user: currentUser,
      errorMessage: message,
    );
  }

  factory ProfileState.sessionExpired([
    String message = 'Session expired. Please sign in again.',
  ]) {
    return ProfileState(
      status: ProfileStatus.sessionExpired,
      errorMessage: message,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get isSuccess => status == ProfileStatus.success;
  bool get isError => status == ProfileStatus.error;
  bool get isSessionExpired => status == ProfileStatus.sessionExpired;

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoggingOut,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isLoggingOut];
}
