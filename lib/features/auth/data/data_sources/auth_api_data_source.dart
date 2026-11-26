import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:simplia_mobile/core/config/app_config.dart';
import 'package:simplia_mobile/core/network/api_exception.dart';
import 'package:simplia_mobile/features/auth/data/models/auth_session_model.dart';
import 'package:simplia_mobile/features/auth/domain/entities/current_user.dart';

class AuthApiDataSource {
  AuthApiDataSource({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<AuthSessionModel> login(String email, String password) async {
    final response = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthSessionModel.fromJson(_body(response));
  }

  Future<AuthSessionModel> refresh(String refreshToken) async {
    final response = await _post('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return AuthSessionModel.fromJson(_body(response));
  }

  Future<void> logout(String refreshToken) async {
    await _post('/auth/logout', {'refreshToken': refreshToken});
  }

  Future<CurrentUser> me(String accessToken) async {
    final response = await _client.get(
      _uri('/auth/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final json = _body(response);
    return CurrentUser(
      id: json['userId'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List<dynamic>),
      permissions: List<String>.from(json['permissions'] as List<dynamic>),
    );
  }

  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  ) async {
    await _post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }, accessToken: accessToken);
  }

  Future<String?> forgotPassword(String email) async {
    final response = await _post('/auth/forgot-password', {'email': email});
    return _body(response)['resetToken'] as String?;
  }

  Future<void> resetPassword(
    String email,
    String token,
    String password,
  ) async {
    await _post('/auth/reset-password', {
      'email': email,
      'resetToken': token,
      'newPassword': password,
    });
  }

  Future<http.Response> _post(
    String path,
    Map<String, String> body, {
    String? accessToken,
  }) {
    return _client.post(
      _uri(path),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, dynamic> _body(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['detail'] as String? ??
          body['title'] as String? ??
          'The request could not be completed.';
    } catch (_) {
      return 'The request could not be completed.';
    }
  }
}
