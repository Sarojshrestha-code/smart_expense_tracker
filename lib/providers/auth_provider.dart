import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = true;

  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _listenToAuthChanges();
  }

  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  bool get isEmailVerified => _user?.emailVerified ?? false;

  void _listenToAuthChanges() {
    _authSubscription = _auth.authStateChanges().listen(
      (User? user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}