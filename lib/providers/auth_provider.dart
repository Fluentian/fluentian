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

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  final _authApi = AuthApi.instance;
  final _apiClient = ApiClient.instance;

  /// Called once at app startup to restore auth state from stored tokens.
  Future<void> initialize() async {
    final hasToken = await _apiClient.hasValidToken();
    if (hasToken) {
      // Try refreshing to get a fresh user object
      try {
        final res = await _authApi.refreshTokens();
        _user = res.user;
        _status = AuthStatus.authenticated;
      } catch (_) {
        // Refresh failed — tokens are stale
        await _apiClient.clearTokens();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Register a new account, then mark user as authenticated.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final res = await _authApi.register(
        username: username,
        email: email,
        password: password,
      );
      _user = res.user;
      _errorMessage = null;
      // Do not set status to authenticated yet, so we can route to onboarding
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

  /// Sign in with email + password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final res = await _authApi.login(email: email, password: password);
      _user = res.user;
      _status = AuthStatus.authenticated;
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
      if (kDebugMode) debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Log out and clear all state.
  Future<void> logout() async {
    _setLoading(true);
    await _authApi.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _setLoading(false);
  }

  /// Update the in-memory user (e.g. after profile save or XP gain).
  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  /// Complete onboarding and transition to authenticated state.
  void completeOnboarding() {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Update profile via API and refresh user object.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await _authApi.updateProfile(data);
      _user = updated;
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
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
}
