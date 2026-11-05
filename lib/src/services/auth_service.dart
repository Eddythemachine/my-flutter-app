import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A user-facing authentication error.
///
/// `FirebaseAuthException.message` is often a developer message ("INVALID_LOGIN_CREDENTIALS")
/// and is not meant for end users, so it is translated into something readable.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin, app-specific wrapper around [FirebaseAuth].
///
/// Keeping Firebase calls in one place means the UI never has to know about
/// `FirebaseAuthException` codes, and it makes the widgets testable.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Fires with the current user (or `null`) on sign-in, sign-out and token
  /// refresh. Listen to this once — not on every `build()`.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      final name = displayName?.trim();
      if (user != null && name != null && name.isNotEmpty) {
        // Best effort: the account already exists, so a failure here must not
        // surface as a failed registration.
        try {
          await user.updateDisplayName(name);
          await user.reload();
        } catch (error) {
          debugPrint('Could not save display name: $error');
        }
      }

      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(messageFor(error));
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(messageFor(error));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(messageFor(error));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(messageFor(error));
    }
  }

  /// Maps Firebase error codes to copy that makes sense to a person.
  static String messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'weak-password':
        return 'That password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this Firebase project.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        final message = error.message;
        return message == null || message.isEmpty
            ? 'Authentication failed. Please try again.'
            : message;
    }
  }
}
