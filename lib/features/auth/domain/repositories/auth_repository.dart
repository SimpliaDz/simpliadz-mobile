import 'package:simplia_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:simplia_mobile/features/auth/domain/entities/current_user.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signIn({required String email, required String password});
  Future<AuthSession> refreshSession();
  Future<void> signOut();
  Future<CurrentUser> getCurrentUser(String accessToken);
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  });
  Future<String?> requestPasswordReset(String email);
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
