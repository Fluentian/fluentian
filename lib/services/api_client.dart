import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../core/endpoints.dart';
import 'app_logger.dart';

/// Central exception class for all API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? responseBody;
  const ApiException(this.statusCode, this.message, [this.responseBody]);

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// User-readable version of the error.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return message;
      case 401:
        final lower = message.toLowerCase();
        if (lower.contains('email') ||
            lower.contains('password') ||
            lower.contains('credential') ||
            lower.contains('invalid') ||
            lower.contains('user') ||
            lower.contains('account') ||
            lower.contains('deactivated') ||
            lower.contains('deleted') ||
            lower.contains('incorrect') ||
            lower.contains('no active account') ||
            lower.contains('verified')) {
          return message;
        }
        return 'Your session expired. Please sign in again.';
      case 403:
        return message;
      case 404:
        return 'Not found.';
      case 409:
        return message; // conflicts (duplicate email) are meaningful
      case 422:
        return message;
      case 429:
        return message;
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
  const NetworkException([
    this.message =
        'No internet connection or server is unreachable. Make sure the backend is running.',
  ]);
  @override
  String toString() => 'NetworkException: $message';
}

/// Singleton HTTP client for all Fluentian API calls.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // ── Global 401 handler ───────────────────────────────
  /// Registered by AuthProvider. Called when any non-login request gets a 401
  /// so the app can force-logout and return the user to the sign-in screen.
  void Function()? onUnauthenticated;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String defaultBaseUrl = '${Endpoints.apiHost}/api/v1';
  static final String _baseUrl = _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : defaultBaseUrl;
  static final Uri _baseUri = Uri.parse(_baseUrl);

  /// One shared client for ALL requests so TLS connections are REUSED
  /// (HTTP keep-alive). Opening a NEW connection to the Hetzner box stalls
  /// 1-14s on its network edge; reusing an existing one is ~0.2s. Capping
  /// maxConnectionsPerHost also limits how many new connections a concurrent
  /// burst can open at once, and idleTimeout keeps them warm across screens.
  static final http.Client _client = IOClient(
    HttpClient()
      ..maxConnectionsPerHost = 2
      ..idleTimeout = const Duration(minutes: 3)
      ..connectionTimeout = const Duration(seconds: 15),
  );

  static String? resolveMediaUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    final parsed = Uri.tryParse(raw);
    if (parsed == null) return raw;

    if (parsed.hasScheme) {
      return _withoutApiPrefixForMedia(parsed).toString();
    }

    final path = parsed.path.startsWith('/') ? parsed.path : '/${parsed.path}';
    return _withoutApiPrefixForMedia(
      _baseUri.replace(
        path: path,
        query: parsed.query.isEmpty ? null : parsed.query,
        fragment: parsed.fragment.isEmpty ? null : parsed.fragment,
      ),
    ).toString();
  }

  static Uri _withoutApiPrefixForMedia(Uri uri) {
    const apiPrefix = '/api/v1';
    const mediaPrefixes = [
      '/media',
      '/static',
      '/uploads',
      '/audio',
      '/assets',
      '/files',
      '/storage',
    ];
    final path = uri.path;
    if (path.startsWith(apiPrefix)) {
      final withoutApi = path.substring(apiPrefix.length);
      if (mediaPrefixes.any(
        (prefix) => withoutApi == prefix || withoutApi.startsWith('$prefix/'),
      )) {
        return uri.replace(path: withoutApi);
      }
    }
    return uri;
  }

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'fluentian_access_token';
  static const _refreshKey = 'fluentian_refresh_token';
  static const _userKey = 'fluentian_cached_user';
  static const _introKey = 'fluentian_seen_intro';
  static const _setupCompleteKey = 'fluentian_setup_complete';

  // ── Cache management ─────────────────────────────────
  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    try {
      final data = await _storage.read(key: _userKey);
      if (data == null || data.isEmpty) return null;
      return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> clearSetupComplete() async {
    await _storage.delete(key: _setupCompleteKey);
  }

  Future<void> setIntroSeen(bool value) async {
    await _storage.write(key: _introKey, value: value.toString());
  }

  Future<bool> hasSeenIntro() async {
    final value = await _storage.read(key: _introKey);
    return value == 'true';
  }

  Future<void> setSetupComplete(bool value) async {
    await _storage.write(key: _setupCompleteKey, value: value.toString());
  }

  Future<bool> hasCompletedSetup() async {
    final value = await _storage.read(key: _setupCompleteKey);
    return value == 'true';
  }

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
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return (access?.isNotEmpty ?? false) || (refresh?.isNotEmpty ?? false);
  }

  // ── Core request methods ──────────────────────────────

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) =>
      _request('GET', path, auth: auth);

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
    Map<String, String>? headers,
  }) => _request('POST', path, body: body, auth: auth, extraHeaders: headers);

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _request('PUT', path, body: body, auth: auth);

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _request('PATCH', path, body: body, auth: auth);

  Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
  }) => _request('DELETE', path, body: body, auth: auth);

  /// A 401 triggers one refresh and one retry, never more. Both `_request`
  /// and `getList` used to recurse into themselves with no counter, so a
  /// server that kept answering 401 while refresh kept succeeding produced an
  /// unbounded retry loop.
  static const int _maxAuthRetries = 1;

  /// Generic list response helper (returns list not map).
  Future<List<dynamic>> getList(
    String path, {
    bool auth = true,
    int authRetries = 0,
  }) async {
    final start = DateTime.now();
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final headers = await _buildHeaders(auth: auth);
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_requestTimeout);
      await _logResponse('GET', uri, response.statusCode, start);

      if (response.statusCode == 401 &&
          auth &&
          authRetries < _maxAuthRetries &&
          !path.contains('/auth/')) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return await getList(path, auth: auth, authRetries: authRetries + 1);
        }
      }

      _checkStatus(response, uri: uri);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) return decoded;
      // Paginated response: return items list
      if (decoded is Map && decoded.containsKey('items')) {
        return decoded['items'] as List<dynamic>;
      }
      return [];
    } on SocketException catch (e) {
      await _logError('GET', uri, start, e);
      throw const NetworkException();
    } on TimeoutException catch (e) {
      // Was unhandled here (only _request mapped it), so a slow response threw
      // a raw TimeoutException past every screen's ApiException/NetworkException
      // handling.
      await _logError('GET', uri, start, e);
      throw const NetworkException('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      await _logError('GET', uri, start, e);
      throw const NetworkException('Connection refused. Is the backend running?');
    } on HttpException catch (e) {
      await _logError('GET', uri, start, e);
      throw const NetworkException('Unable to reach server.');
    }
  }

  // ── Internal ──────────────────────────────────────────

  Future<bool>? _refreshFuture;

  Future<bool> _tryRefreshToken() async {
    final inFlight = _refreshFuture;
    if (inFlight != null) return inFlight;
    final future = _refreshTokensOnce();
    _refreshFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshFuture, future)) _refreshFuture = null;
    }
  }

  /// Refresh got a *shorter* deadline (10s) than the 15s request it exists to
  /// rescue. On this backend a cold TLS handshake alone has been measured near
  /// 14s, so refresh timed out first, returned false, and the caller surfaced
  /// the original 401 -- signing the user out while their credentials were
  /// perfectly valid. It now gets at least as long as a normal request.
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const Duration _refreshTimeout = Duration(seconds: 20);

  Future<bool> _refreshTokensOnce() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final uri = Uri.parse('$_baseUrl/auth/refresh');
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(_refreshTimeout);

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final newAccess = data['access_token']?.toString();
        final newRefresh = data['refresh_token']?.toString() ?? refreshToken;
        if (newAccess != null && newAccess.isNotEmpty) {
          await saveTokens(newAccess, newRefresh);
          return true;
        }
      }
      // A 401/403 here means the refresh token really is dead; anything else
      // (5xx, timeout, socket drop) is transient and must not read as
      // "signed out". The caller distinguishes them via the thrown type.
      if (response.statusCode == 401 || response.statusCode == 403) {
        return false;
      }
      throw const NetworkException('Could not refresh your session.');
    } on NetworkException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException('Could not refresh your session.');
    } on SocketException {
      throw const NetworkException('Could not refresh your session.');
    } catch (e) {
      await AppLogger.instance.error('Token refresh failed', e);
      return false;
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    Map<String, String>? extraHeaders,
    int authRetries = 0,
  }) async {
    final start = DateTime.now();
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final headers = await _buildHeaders(auth: auth);
      if (extraHeaders != null) headers.addAll(extraHeaders);

      http.Response response;
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(_requestTimeout);
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(_requestTimeout);
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(_requestTimeout);
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: jsonEncode(body))
              .timeout(_requestTimeout);
        case 'DELETE':
          response = await _client
              .delete(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(_requestTimeout);
        default:
          throw ApiException(0, 'Unknown HTTP method: $method');
      }

      await _logResponse(method, uri, response.statusCode, start);

      if (response.statusCode == 401 &&
          auth &&
          authRetries < _maxAuthRetries &&
          !path.contains('/auth/')) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return await _request(
            method,
            path,
            body: body,
            auth: auth,
            extraHeaders: extraHeaders,
            authRetries: authRetries + 1,
          );
        }
      }

      _checkStatus(response, uri: uri);
      if (response.body.isEmpty) return {};
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } on SocketException catch (e) {
      await _logError(method, uri, start, e);
      throw const NetworkException();
    } on HttpException catch (e) {
      await _logError(method, uri, start, e);
      throw const NetworkException('Unable to reach server.');
    } on TimeoutException catch (e) {
      // Was matched by `e.toString().contains('TimeoutException')` in a bare
      // catch, which also swallowed the stack trace of anything it matched.
      await _logError(method, uri, start, e);
      throw const NetworkException('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      await _logError(method, uri, start, e);
      throw const NetworkException(
        'Connection refused. Is the backend running?',
      );
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

  void _checkStatus(http.Response response, {Uri? uri}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'Request failed';
    Map<String, dynamic>? responseBody;
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        responseBody = Map<String, dynamic>.from(body);
        message =
            body['message']?.toString() ??
            body['detail']?.toString() ??
            message;
      }
    } catch (_) {
      // ignore parse errors on error bodies
    }
    if (kDebugMode) {
      debugPrint(
        'API Error ${response.statusCode} ${uri?.path ?? ''}: $message',
      );
      final body = utf8.decode(response.bodyBytes);
      if (body.isNotEmpty) {
        debugPrint('API Error body: $body');
      }
    }
    // Fire global sign-out on unexpected 401s (e.g. token expired, account
    // deleted) so the app never gets stuck in an infinite-loading loop.
    if (response.statusCode == 401) {
      onUnauthenticated?.call();
    }
    throw ApiException(response.statusCode, message, responseBody);
  }

  Future<void> _logResponse(
    String method,
    Uri uri,
    int statusCode,
    DateTime start,
  ) async {
    final elapsedMs = DateTime.now().difference(start).inMilliseconds;
    await AppLogger.instance.info(
      'API $method ${uri.path} -> $statusCode (${elapsedMs}ms)',
    );
  }

  Future<void> _logError(
    String method,
    Uri uri,
    DateTime start,
    Object error,
  ) async {
    final elapsedMs = DateTime.now().difference(start).inMilliseconds;
    await AppLogger.instance.error(
      'API $method ${uri.path} failed (${elapsedMs}ms)',
      error,
    );
  }
}
