import 'package:simpliadz_mobile/core/network/api_exception.dart';
import 'package:simpliadz_mobile/features/auth/data/data_sources/auth_api_data_source.dart';
import 'package:simpliadz_mobile/features/auth/data/storage/refresh_token_store.dart';
import 'package:simpliadz_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:simpliadz_mobile/features/auth/domain/entities/current_user.dart';
import 'package:simpliadz_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._tokenStore);

  final AuthApiDataSource _api;
  final RefreshTokenStore _tokenStore;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = (await _api.login(email, password)).toEntity();
    await _tokenStore.write(session.refreshToken);
    return session;
  }

  @override
  Future<AuthSession> refreshSession() async {
    final refreshToken = await _tokenStore.read();
    if (refreshToken == null) {
      throw const ApiException('No stored session was found.');
    }
    final session = (await _api.refresh(refreshToken)).toEntity();
    await _tokenStore.write(session.refreshToken);
    return session;
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _tokenStore.read();
    try {
      if (refreshToken != null) await _api.logout(refreshToken);
    } finally {
      await _tokenStore.clear();
    }
  }

  @override
  Future<CurrentUser> getCurrentUser(String accessToken) =>
      _api.me(accessToken);

  @override
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.changePassword(accessToken, currentPassword, newPassword);
    await _tokenStore.clear();
  }

  @override
  Future<String?> requestPasswordReset(String email) =>
      _api.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) => _api.resetPassword(email, resetToken, newPassword);
}
