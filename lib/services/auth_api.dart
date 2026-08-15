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
    await _client.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    }, auth: false);
  }

  /// Verify signup OTP. Returns [AuthResponse] with tokens + user.
  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final json = await _client.post('/auth/verify-email', {
      'email': email,
      'otp': otp,
    }, auth: false);
    final res = AuthResponse.fromJson(json);
    await _client.saveTokens(res.accessToken, res.refreshToken);
    return res;
  }

  /// Resend signup OTP.
  Future<void> resendOtp({required String email}) async {
    await _client.post('/auth/resend-otp', {'email': email}, auth: false);
  }

  /// Log in with email + password.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    }, auth: false);
    final res = AuthResponse.fromJson(json);
    await _client.saveTokens(res.accessToken, res.refreshToken);
    return res;
  }

  /// Exchange a Firebase ID token for Fluentian backend tokens.
  Future<AuthResponse> loginWithFirebase({required String idToken}) async {
    final json = await _client.post('/auth/firebase', {
      'id_token': idToken,
    }, auth: false);
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
    final json = await _client.post('/auth/refresh', {
      'refresh_token': refreshToken,
    }, auth: false);
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
    await _client.post('/auth/forgot-password', {'email': email}, auth: false);
  }

  /// Reset password using the code from the email.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await _client.post('/auth/reset-password', {
      'email': email,
      'token': token,
      'new_password': newPassword,
    }, auth: false);
  }

  /// Update user profile data (e.g. during onboarding).
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final json = await _client.put('/users/me', data);
    return UserModel.fromJson(json);
  }

  Future<UserModel> updateUser(Map<String, dynamic> data) async {
    final json = await _client.patch('/users/me', data);
    return UserModel.fromJson(json);
  }

  /// Update user settings fields.
  Future<void> updateSettings(Map<String, dynamic> data) async {
    await _client.patch('/users/me/settings', data);
  }

  /// Request an email OTP before account deletion.
  Future<void> requestDeletionOtp({required String email}) async {
    await _client.post('/users/request-deletion-otp', {'email': email});
  }

  /// Confirm deletion OTP and soft-delete the account.
  Future<void> confirmDeletionOtp({
    required String email,
    required String code,
    String? reasonCode,
    String? reasonDetails,
  }) async {
    await _client.post('/users/confirm-deletion-otp', {
      'email': email,
      'code': code,
      if (reasonCode != null) 'reason_code': reasonCode,
      if (reasonDetails != null) 'reason_details': reasonDetails,
    });
  }

  /// Fetch the persisted heart count for the current user.
  Future<HeartStatus> getHearts() async {
    final json = await _client.get('/users/me/hearts');
    return HeartStatus.fromJson(json);
  }

  /// Persistently spend one heart after a wrong answer.
  Future<HeartStatus> spendHeart() async {
    final json = await _client.post('/users/me/hearts/spend', {});
    return HeartStatus.fromJson(json);
  }
}
