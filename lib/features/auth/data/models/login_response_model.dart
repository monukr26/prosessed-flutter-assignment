import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

/// Response payload returned by POST /auth/login.
class LoginResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON returns tokens as accessToken / token
    final accessToken =
        json['accessToken'] as String? ?? json['token'] as String? ?? '';
    final refreshToken = json['refreshToken'] as String? ?? '';
    final user = UserModel.fromJson(json);

    return LoginResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      ...user.toJson(),
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
