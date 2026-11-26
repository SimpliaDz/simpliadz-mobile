import 'package:simplia_mobile/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.email,
    required this.roles,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAtUtc'] as String,
      ),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.parse(
        json['refreshTokenExpiresAtUtc'] as String,
      ),
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List<dynamic>),
    );
  }

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String email;
  final List<String> roles;

  AuthSession toEntity() => AuthSession(
    accessToken: accessToken,
    accessTokenExpiresAt: accessTokenExpiresAt,
    refreshToken: refreshToken,
    refreshTokenExpiresAt: refreshTokenExpiresAt,
    email: email,
    roles: roles,
  );
}
