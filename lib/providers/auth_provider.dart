import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/app_logger.dart';
import '../services/auth_api.dart';
import '../services/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Global auth state — consumed via Provider throughout the app.
class AuthProvider extends ChangeNotifier {
  static const errorDisplayDuration = Duration(seconds: 2);
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  Timer? _errorDismissTimer;
  bool _isLoading = false;
  bool _hasSeenIntro = false;
  bool _hasCompletedSetup = false;
  String? _unverifiedEmail;
  int _maxHearts = 5;
  DateTime? _nextHeartRefillAt;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasSeenIntro => _hasSeenIntro;
  bool get hasCompletedSetup => _hasCompletedSetup;
  String? get unverifiedEmail => _unverifiedEmail;
  int get maxHearts => _maxHearts;
  DateTime? get nextHeartRefillAt =>
      _nextHeartRefillAt ?? _user?.nextHeartRefillAt;

  final _authApi = AuthApi.instance;
  final _apiClient = ApiClient.instance;
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  /// Called once at app startup to restore auth state from stored tokens.
  Future<void> initialize() async {
    final startTime = DateTime.now();
    await AppLogger.instance.info('Auth initialize started');
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
        _nextHeartRefillAt = res.user.nextHeartRefillAt;
        _hasCompletedSetup = _hasCompletedSetup || _hasFinishedSetup(res.user);
        _status = AuthStatus.authenticated;
        await _apiClient.saveUser(res.user);
        await AppLogger.instance.info('Auth restored for ${res.user.email}');
      } catch (e) {
        if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
          await _apiClient.clearTokens();
          await _apiClient.clearUser();
          _user = null;
          _status = AuthStatus.unauthenticated;
          await AppLogger.instance.warning('Stored auth token was rejected');
        } else {
          // Network or server error, use cached session if present
          if (cachedUser != null) {
            _user = cachedUser;
            _nextHeartRefillAt = cachedUser.nextHeartRefillAt;
            _hasCompletedSetup =
                _hasCompletedSetup || _hasFinishedSetup(cachedUser);
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.unauthenticated;
          }
          await AppLogger.instance.error('Auth restore fallback used', e);
        }
      }
    } else {
      _status = AuthStatus.unauthenticated;
      _user = null;
      await AppLogger.instance.info('No stored auth token found');
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
      await AppLogger.instance.info('Registration started for $email');
      await _authApi.register(
        username: username,
        email: email,
        password: password,
      );
      _unverifiedEmail = email;
      _errorMessage = null;
      await AppLogger.instance.info(
        'Registration created verification for $email',
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      await AppLogger.instance.error('Registration API error for $email', e);
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      await AppLogger.instance.error(
        'Registration network error for $email',
        e,
      );
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      await AppLogger.instance.error(
        'Registration unexpected error for $email',
        e,
      );
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
      _nextHeartRefillAt = res.user.nextHeartRefillAt;
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
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _unverifiedEmail = null;
    try {
      await AppLogger.instance.info('Login started for $email');
      final res = await _authApi.login(email: email, password: password);
      _user = res.user;
      _nextHeartRefillAt = res.user.nextHeartRefillAt;
      _hasCompletedSetup = _hasCompletedSetup || _hasFinishedSetup(res.user);
      await _apiClient.saveUser(res.user);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      await AppLogger.instance.info('Login succeeded for ${res.user.email}');
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      if (e.message == 'Email not verified') {
        _unverifiedEmail = e.responseBody?['detail']?.toString() ?? email;
      }
      await AppLogger.instance.error('Login API error for $email', e);
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      await AppLogger.instance.error('Login network error for $email', e);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      await AppLogger.instance.error('Login unexpected error for $email', e);
      if (kDebugMode) debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _errorMessage = null;
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final firebaseUserCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final idToken = await firebaseUserCredential.user?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw firebase_auth.FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Could not get Google sign-in token.',
        );
      }

      final res = await _authApi.loginWithFirebase(idToken: idToken);
      _user = res.user;
      _nextHeartRefillAt = res.user.nextHeartRefillAt;
      _hasCompletedSetup = _hasCompletedSetup || _hasFinishedSetup(res.user);
      await _apiClient.saveUser(res.user);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Google sign-in failed.';
      if (kDebugMode) {
        debugPrint('Firebase Google sign-in error [${e.code}]: ${e.message}');
      }
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return false;
    } on PlatformException catch (e) {
      final raw = '${e.message ?? ''} ${e.details ?? ''}';
      if (raw.contains('ApiException: 10')) {
        _errorMessage =
            'Google Sign-In is not configured for this Android app. Add the debug SHA-1/SHA-256 fingerprints in Firebase, then replace google-services.json.';
      } else {
        _errorMessage = e.message ?? 'Google sign-in failed.';
      }
      if (kDebugMode) {
        debugPrint(
          'Google platform sign-in error [${e.code}]: ${e.message} ${e.details}',
        );
      }
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      if (kDebugMode) debugPrint('Google sign-in error: $e');
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
    final email = _user?.email ?? 'unknown user';
    await AppLogger.instance.info('Logout started for $email');
    try {
      await _authApi.logout();
    } catch (e) {
      await AppLogger.instance.error('Backend logout failed for $email', e);
    }
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      await AppLogger.instance.error('Firebase logout failed for $email', e);
    }
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      await AppLogger.instance.error('Google logout failed for $email', e);
    } finally {
      await _apiClient.clearTokens();
      await _apiClient.clearUser();
      await _apiClient.clearSetupComplete();
      _user = null;
      _unverifiedEmail = null;
      _nextHeartRefillAt = null;
      _maxHearts = 5;
      _hasCompletedSetup = false;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      _setLoading(false);
      await AppLogger.instance.info('Local logout cleanup finished for $email');
    }
  }

  /// Permanently delete the account, then clear every local session artifact.
  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await _authApi.deleteAccount();
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await _apiClient.clearTokens();
      await _apiClient.clearUser();
      await _apiClient.clearSetupComplete();
      _user = null;
      _unverifiedEmail = null;
      _nextHeartRefillAt = null;
      _hasCompletedSetup = false;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not delete your account. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update the in-memory user (e.g. after profile save or XP gain).
  void updateUser(UserModel updated) async {
    _user = updated;
    await _apiClient.saveUser(updated);
    notifyListeners();
  }

  void updateUserStats({
    int? hearts,
    int? xpTotal,
    int? streakDays,
    DateTime? nextHeartRefillAt,
    bool updateNextHeartRefill = false,
  }) async {
    final previous = _user;
    if (previous == null) return;
    if (updateNextHeartRefill) {
      _nextHeartRefillAt = nextHeartRefillAt;
    }
    _user = previous.copyWith(
      hearts: hearts,
      xpTotal: xpTotal,
      streakDays: streakDays,
      nextHeartRefillAt: nextHeartRefillAt,
      clearNextHeartRefillAt:
          updateNextHeartRefill && nextHeartRefillAt == null,
    );
    await _apiClient.saveUser(_user!);
    notifyListeners();
  }

  Future<int?> refreshHearts() async {
    try {
      final status = await _authApi.getHearts();
      _maxHearts = status.maxHearts;
      updateUserStats(
        hearts: status.hearts,
        nextHeartRefillAt: status.nextRefillAt,
        updateNextHeartRefill: true,
      );
      return status.hearts;
    } catch (e) {
      if (kDebugMode) debugPrint('Refresh hearts error: $e');
      return _user?.hearts;
    }
  }

  Future<int?> spendHeart() async {
    try {
      final status = await _authApi.spendHeart();
      _maxHearts = status.maxHearts;
      updateUserStats(
        hearts: status.hearts,
        nextHeartRefillAt: status.nextRefillAt,
        updateNextHeartRefill: true,
      );
      return status.hearts;
    } catch (e) {
      if (kDebugMode) debugPrint('Spend heart error: $e');
      return null;
    }
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

  Future<bool> updateLearningLanguage(String languageCode) async {
    final previous = _user;
    if (previous == null) return false;
    _user = previous.copyWith(baseLanguageCode: languageCode);
    notifyListeners();
    try {
      final updated = await _authApi.updateUser({
        'base_language_code': languageCode,
      });
      _user = updated;
      await _apiClient.saveUser(updated);
      notifyListeners();
      return true;
    } catch (e) {
      _user = previous;
      notifyListeners();
      if (kDebugMode) debugPrint('Update learning language error: $e');
      return false;
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> data) async {
    final previous = _user;
    if (previous == null) return false;
    _user = previous.copyWith(
      dailyGoalMinutes: data['daily_goal_minutes'] as int?,
      notificationsEnabled: data['notifications_enabled'] as bool?,
      autoplayAudio: data['autoplay_audio'] as bool?,
      soundEnabled: data['sound_enabled'] as bool?,
      learningReminderEnabled: data['learning_reminder_enabled'] as bool?,
      reminderTime: data['reminder_time'] as String?,
      phoneticHintsEnabled: data['phonetic_hints_enabled'] as bool?,
      speakingExercisesEnabled: data['speaking_exercises_enabled'] as bool?,
      highContrastEnabled: data['high_contrast_enabled'] as bool?,
      reduceAnimationsEnabled: data['reduce_animations_enabled'] as bool?,
      hapticFeedbackEnabled: data['haptic_feedback_enabled'] as bool?,
      ttsSpeed: data['tts_speed'] as double?,
      fontScale: data['font_scale'] as int?,
    );
    notifyListeners();
    try {
      await _authApi.updateSettings(data);
      final updated = _user;
      if (updated != null) {
        await _apiClient.saveUser(updated);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _user = previous;
      notifyListeners();
      if (kDebugMode) debugPrint('Update settings error: $e');
      return false;
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
    _errorDismissTimer?.cancel();
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _scheduleErrorDismissal() {
    _errorDismissTimer?.cancel();
    if (_errorMessage == null) return;
    _errorDismissTimer = Timer(errorDisplayDuration, clearError);
  }

  void _setLoading(bool val) {
    if (val) {
      _errorDismissTimer?.cancel();
      _errorMessage = null;
    } else if (_errorMessage != null) {
      _scheduleErrorDismissal();
    }
    _isLoading = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _errorDismissTimer?.cancel();
    super.dispose();
  }

  bool _hasFinishedSetup(UserModel user) =>
      user.currentLevel.trim().isNotEmpty &&
      user.currentLevel.toUpperCase() != 'A0';
}
