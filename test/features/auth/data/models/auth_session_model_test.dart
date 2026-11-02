import 'package:flutter_test/flutter_test.dart';
import 'package:simpliadz_mobile/features/auth/data/models/auth_session_model.dart';

void main() {
  test('maps the API login response to an authentication session', () {
    final model = AuthSessionModel.fromJson({
      'accessToken': 'access-token',
      'accessTokenExpiresAtUtc': '2026-11-02T12:00:00Z',
      'refreshToken': 'refresh-token',
      'refreshTokenExpiresAtUtc': '2026-11-16T12:00:00Z',
      'email': 'admin@dev.local',
      'roles': ['Administrator'],
    });

    final session = model.toEntity();

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.email, 'admin@dev.local');
    expect(session.roles, ['Administrator']);
  });
}
