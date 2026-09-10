import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Send verification email immediately after registration
    final user = credential.user;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }

    return credential;
  }

  // Login existing user
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Send verification email again
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    if (user.emailVerified) {
      return;
    }

    await user.sendEmailVerification();
  }

  // Refresh Firebase user information and check verification status
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;

    return refreshedUser?.emailVerified ?? false;
  }

  // Forgot password
  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}