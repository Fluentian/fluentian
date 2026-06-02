import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_api.dart';
import '../services/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Global auth state — consumed via Provider throughout the app.
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasSeenIntro = false;
  bool _hasCompletedSetup = false;
  String? _unverifiedEmail;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasSeenIntro => _hasSeenIntro;
  bool get hasCompletedSetup => _hasCompletedSetup;
  String? get unverifiedEmail => _unverifiedEmail;

  final _authApi = AuthApi.instance;
  final _apiClient = ApiClient.instance;

  /// Called once at app startup to restore auth state from stored tokens.
  Future<void> initialize() async {
    final startTime = DateTime.now();
    try {
      _hasSeenIntro = await _apiClient.hasSeenIntro();
    } catch (e) {
      _hasSeenIntro = false;
      if (kDebugMode) debugPrint('Intro flag read error: $e');
    }
    try {
      _hasCompletedSetup = await _apiClient.hasCompletedSetup();
    } catch (e) {
      _hasCompletedSetup = false;
      if (kDebugMode) debugPrint('Setup flag read error: $e');
    }
    final cachedUser = await _apiClient.getUser();

    final hasToken = await _apiClient.hasValidToken();
    if (hasToken) {
      try {
        final res = await _authApi.refreshTokens();
        _user = res.user;
        _hasCompletedSetup = _hasCompletedSetup || _hasFinishedSetup(res.user);
        _status = AuthStatus.authenticated;
        await _apiClient.saveUser(res.user);
      } catch (e) {
        if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
          await _apiClient.clearTokens();
          await _apiClient.clearUser();
          _user = null;
          _status = AuthStatus.unauthenticated;
        } else {
          // Network or server error, use cached session if present
          if (cachedUser != null) {
            _user = cachedUser;
            _hasCompletedSetup =
                _hasCompletedSetup || _hasFinishedSetup(cachedUser);
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.unauthenticated;
          }
        }
      }
    } else {
      _status = AuthStatus.unauthenticated;
      _user = null;
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = 2500 - elapsed;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
    notifyListeners();
  }

  /// Register a new account (email verification will be required).
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _unverifiedEmail = null;
    try {
      await _authApi.register(
        username: username,
        email: email,
        password: password,
      );
      _unverifiedEmail = email;
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      if (kDebugMode) debugPrint('Register error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify signup OTP.
  Future<bool> verifyEmailOtp(String otp) async {
    if (_unverifiedEmail == null) {
      _errorMessage = 'No email to verify.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    try {
      final res = await _authApi.verifyEmail(
        email: _unverifiedEmail!,
        otp: otp,
      );
      _user = res.user;
      _hasCompletedSetup = _hasFinishedSetup(res.user);
      await _apiClient.saveUser(res.user);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _unverifiedEmail = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend signup verification OTP.
  Future<bool> resendVerificationOtp() async {
    if (_unverifiedEmail == null) return false;
    _setLoading(true);
    try {
      await _authApi.resendOtp(email: _unverifiedEmail!);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email + password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _unverifiedEmail = null;
    try {
      final res = await _authApi.login(email: email, password: password);
      _user = res.user;
      _hasCompletedSetup = _hasCompletedSetup || _hasFinishedSetup(res.user);
      await _apiClient.saveUser(res.user);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      if (e.message == 'Email not verified') {
        _unverifiedEmail = e.responseBody?['detail']?.toString() ?? email;
      }
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      if (kDebugMode) debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset OTP.
  Future<bool> sendPasswordResetOtp(String email) async {
    _setLoading(true);
    _unverifiedEmail = null;
    try {
      await _authApi.forgotPassword(email);
      _unverifiedEmail = email;
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password using OTP.
  Future<bool> resetPasswordWithOtp(String otp, String newPassword) async {
    if (_unverifiedEmail == null) {
      _errorMessage = 'No active reset session. Please request a new code.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    try {
      await _authApi.resetPassword(
        email: _unverifiedEmail!,
        token: otp,
        newPassword: newPassword,
      );
      _errorMessage = null;
      _unverifiedEmail = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Log out and clear all state.
  Future<void> logout() async {
    _setLoading(true);
    await _authApi.logout();
    await _apiClient.clearUser();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _setLoading(false);
  }

  /// Update the in-memory user (e.g. after profile save or XP gain).
  void updateUser(UserModel updated) async {
    _user = updated;
    await _apiClient.saveUser(updated);
    notifyListeners();
  }

  /// Complete onboarding and transition to authenticated state.
  Future<void> completeOnboarding({String? selectedLevel}) async {
    UserModel? updatedUser;
    if (selectedLevel != null && _user != null) {
      _user = _user!.copyWith(currentLevel: selectedLevel);
      updatedUser = _user;
    }
    _hasCompletedSetup = true;
    _status = AuthStatus.authenticated;
    notifyListeners();
    if (updatedUser != null) {
      try {
        await _apiClient.saveUser(updatedUser);
      } catch (e) {
        if (kDebugMode) debugPrint('Onboarding user cache write error: $e');
      }
    }
    try {
      await _apiClient.setSetupComplete(true);
    } catch (e) {
      if (kDebugMode) debugPrint('Setup flag write error: $e');
    }
  }

  /// Update profile via API and refresh user object.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await _authApi.updateProfile(data);
      _user = updated;
      _hasCompletedSetup = _hasCompletedSetup || _hasFinishedSetup(updated);
      await _apiClient.saveUser(updated);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> setIntroSeen(bool value) async {
    _hasSeenIntro = value;
    notifyListeners();
    try {
      await _apiClient.setIntroSeen(value);
    } catch (e) {
      if (kDebugMode) debugPrint('Intro flag write error: $e');
    }
  }

  /// Clear error so the UI can reset after showing a snackbar.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool _hasFinishedSetup(UserModel user) =>
      user.currentLevel.trim().isNotEmpty &&
      user.currentLevel.toUpperCase() != 'A0';
}
