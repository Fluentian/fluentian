import '../models/user_model.dart';
import 'api_client.dart';

/// Calls the Fluentian backend auth endpoints.
class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  final _client = ApiClient.instance;

  /// Register a new user.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _client.post(
      '/auth/register',
      {
        'username': username,
        'email': email,
        'password': password,
      },
      auth: false,
    );
  }

  /// Verify signup OTP. Returns [AuthResponse] with tokens + user.
  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final json = await _client.post(
      '/auth/verify-email',
      {
        'email': email,
        'otp': otp,
      },
      auth: false,
    );
    final res = AuthResponse.fromJson(json);
    await _client.saveTokens(res.accessToken, res.refreshToken);
    return res;
  }

  /// Resend signup OTP.
  Future<void> resendOtp({
    required String email,
  }) async {
    await _client.post(
      '/auth/resend-otp',
      {
        'email': email,
      },
      auth: false,
    );
  }

  /// Log in with email + password.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );
    final res = AuthResponse.fromJson(json);
    await _client.saveTokens(res.accessToken, res.refreshToken);
    return res;
  }

  /// Refresh the access token using the stored refresh token.
  Future<AuthResponse> refreshTokens() async {
    final refreshToken = await _client.getRefreshToken();
    if (refreshToken == null) {
      throw const ApiException(401, 'No refresh token found');
    }
    final json = await _client.post(
      '/auth/refresh',
      {'refresh_token': refreshToken},
      auth: false,
    );
    final res = AuthResponse.fromJson(json);
    await _client.saveTokens(res.accessToken, res.refreshToken);
    return res;
  }

  /// Log out and revoke tokens on the server.
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', {});
    } catch (_) {
      // Even if server call fails, clear local tokens
    } finally {
      await _client.clearTokens();
    }
  }

  /// Request a password reset email.
  Future<void> forgotPassword(String email) async {
    await _client.post(
      '/auth/forgot-password',
      {'email': email},
      auth: false,
    );
  }

  /// Reset password using the code from the email.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await _client.post(
      '/auth/reset-password',
      {
        'email': email,
        'token': token,
        'new_password': newPassword,
      },
      auth: false,
    );
  }

  /// Update user profile data (e.g. during onboarding).
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final json = await _client.put(
      '/users/me',
      data,
    );
    return UserModel.fromJson(json);
  }
}
