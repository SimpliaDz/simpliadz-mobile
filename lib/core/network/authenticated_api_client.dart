import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:simpliadz_mobile/core/config/app_config.dart';
import 'package:simpliadz_mobile/core/network/api_exception.dart';

typedef AccessTokenProvider = Future<String?> Function({bool refresh});

class AuthenticatedApiClient {
  AuthenticatedApiClient({required this._tokenProvider, http.Client? client})
    : _client = client ?? http.Client();

  final AccessTokenProvider _tokenProvider;
  final http.Client _client;

  Future<Map<String, dynamic>> get(String path) async {
    return await getDynamic(path) as Map<String, dynamic>;
  }

  Future<dynamic> getDynamic(String path) async {
    var response = await _get(path, refresh: false);
    if (response.statusCode == 401) {
      response = await _get(path, refresh: true);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(response), statusCode: response.statusCode);
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> postDynamic(String path, Object? body) async {
    var response = await _post(path, body, refresh: false);
    if (response.statusCode == 401) {
      response = await _post(path, body, refresh: true);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(response), statusCode: response.statusCode);
    }
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  Future<http.Response> _get(String path, {required bool refresh}) async {
    final token = await _tokenProvider(refresh: refresh);
    if (token == null) {
      throw const ApiException('Your session has ended.', statusCode: 401);
    }
    return _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> _post(
    String path,
    Object? body, {
    required bool refresh,
  }) async {
    final token = await _tokenProvider(refresh: refresh);
    if (token == null) {
      throw const ApiException('Your session has ended.', statusCode: 401);
    }
    return _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );
  }

  String _message(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['detail'] as String? ??
          body['title'] as String? ??
          'Request failed.';
    } catch (_) {
      return 'Request failed.';
    }
  }
}
