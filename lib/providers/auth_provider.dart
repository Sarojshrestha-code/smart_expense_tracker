 import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _listenToAuthState();
  }

  // =========================
  // GETTERS
  // =========================

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// Used by main.dart for authentication protection.
  bool get isAuthenticated => _user != null;

  /// Alternative name if needed elsewhere.
  bool get isLoggedIn => _user != null;

  bool get isEmailVerified => _user?.emailVerified ?? false;

  // =========================
  // AUTH STATE
  // =========================

  void _listenToAuthState() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // =========================
  // LOGIN
  // =========================

  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      _user = credential.user;
      notifyListeners();

      return credential;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseErrorMessage(e);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Login error: $e');

      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REGISTER
  // =========================

  Future<UserCredential?> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.register(
        email: email,
        password: password,
      );

      _user = credential.user;
      notifyListeners();

      return credential;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseErrorMessage(e);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Registration error: $e');

      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // EMAIL VERIFICATION
  // =========================

  Future<bool> sendVerificationEmail() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendVerificationEmail();
      return true;
    } catch (e) {
      debugPrint('Verification email error: $e');

      _errorMessage = 'Unable to send verification email.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      final verified = await _authService.isEmailVerified();

      await FirebaseAuth.instance.currentUser?.reload();

      _user = FirebaseAuth.instance.currentUser;

      notifyListeners();

      return verified;
    } catch (e) {
      debugPrint('Email verification check error: $e');

      _errorMessage = 'Unable to check verification status.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<bool> resetPassword({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(
        email: email,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _firebaseErrorMessage(e);
      notifyListeners();

      return false;
    } catch (e) {
      debugPrint('Password reset error: $e');

      _errorMessage = 'Unable to reset password.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();

      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');

      _errorMessage = 'Unable to sign out. Please try again.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // ERROR MANAGEMENT
  // =========================

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}