import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central exception class for all API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// User-readable version of the error.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return message;
      case 401:
        return 'Your session expired. Please sign in again.';
      case 403:
        return 'You don\'t have permission to do that.';
      case 404:
        return 'Not found.';
      case 409:
        return message; // conflicts (duplicate email) are meaningful
      case 422:
        return message;
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (code $statusCode).';
    }
  }
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);
  @override
  String toString() => 'NetworkException: $message';
}

/// Singleton HTTP client for all Fluentian API calls.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // ── Configuration ────────────────────────────────────
  // Change this to your backend URL (localhost for emulator, LAN IP for device)
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1';
  // For physical device on same network use e.g. 'http://192.168.1.x:8000/api/v1'

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'fluentian_access_token';
  static const _refreshKey = 'fluentian_refresh_token';

  // ── Token management ─────────────────────────────────
  Future<void> saveTokens(String access, String refresh) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Core request methods ──────────────────────────────

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) =>
      _request('GET', path, auth: auth);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
          {bool auth = true}) =>
      _request('POST', path, body: body, auth: auth);

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body,
          {bool auth = true}) =>
      _request('PUT', path, body: body, auth: auth);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body,
          {bool auth = true}) =>
      _request('PATCH', path, body: body, auth: auth);

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) =>
      _request('DELETE', path, auth: auth);

  /// Generic list response helper (returns list not map).
  Future<List<dynamic>> getList(String path, {bool auth = true}) async {
    try {
      final headers = await _buildHeaders(auth: auth);
      final uri = Uri.parse('$_baseUrl$path');
      final response =
          await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      _checkStatus(response);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) return decoded;
      // Paginated response: return items list
      if (decoded is Map && decoded.containsKey('items')) {
        return decoded['items'] as List<dynamic>;
      }
      return [];
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException('Unable to reach server.');
    }
  }

  // ── Internal ──────────────────────────────────────────

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final headers = await _buildHeaders(auth: auth);
      final uri = Uri.parse('$_baseUrl$path');

      http.Response response;
      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
        case 'PATCH':
          response = await http
              .patch(uri, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
        default:
          throw ApiException(0, 'Unknown HTTP method: $method');
      }

      _checkStatus(response);
      if (response.body.isEmpty) return {};
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException('Unable to reach server.');
    }
  }

  Future<Map<String, String>> _buildHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'Request failed';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        message = body['detail']?.toString() ??
            body['message']?.toString() ??
            message;
      }
    } catch (_) {
      // ignore parse errors on error bodies
    }
    if (kDebugMode) {
      debugPrint('API Error ${response.statusCode}: $message');
    }
    throw ApiException(response.statusCode, message);
  }
}
