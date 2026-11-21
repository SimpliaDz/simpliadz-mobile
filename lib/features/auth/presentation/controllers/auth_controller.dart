import 'package:flutter/foundation.dart';
import 'package:simpliadz_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:simpliadz_mobile/features/auth/domain/entities/current_user.dart';
import 'package:simpliadz_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;
  AuthSession? _session;
  CurrentUser? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthSession? get session => _session;
  CurrentUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _session != null;

  Future<String?> accessToken({bool refresh = false}) async {
    if (refresh && !await refreshSession()) return null;
    return _session?.accessToken;
  }

  Future<bool> signIn(String email, String password) async {
    return _run(() async {
      _session = await _repository.signIn(email: email, password: password);
      _currentUser = await _repository.getCurrentUser(_session!.accessToken);
    });
  }

  Future<bool> restoreSession() async {
    return _run(() async {
      _session = await _repository.refreshSession();
      _currentUser = await _repository.getCurrentUser(_session!.accessToken);
    });
  }

  Future<bool> refreshSession() async {
    return _run(() async {
      _session = await _repository.refreshSession();
      _currentUser = await _repository.getCurrentUser(_session!.accessToken);
    });
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final session = _session;
    if (session == null) return false;
    final succeeded = await _run(
      () => _repository.changePassword(
        accessToken: session.accessToken,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    if (succeeded) {
      _session = null;
      _currentUser = null;
      notifyListeners();
    }
    return succeeded;
  }

  Future<String?> requestPasswordReset(String email) async {
    String? token;
    await _run(() async {
      token = await _repository.requestPasswordReset(email);
    });
    return token;
  }

  Future<bool> resetPassword(
    String email,
    String resetToken,
    String newPassword,
  ) => _run(
    () => _repository.resetPassword(
      email: email,
      resetToken: resetToken,
      newPassword: newPassword,
    ),
  );

  Future<void> signOut() async {
    await _repository.signOut();
    _session = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      _errorMessage = 'We could not complete that request. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
