import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/auth/auth_exceptions.dart'; // 👈 Added .dart here

Exception translateAuthException(FirebaseAuthException e) {
  switch (e.code) {
    // Login
    case 'user-not-found':
    case 'invalid-credential':
      return UserNotFoundAuthException();
    case 'wrong-password':
      return WrongPasswordAuthException();

    // Register
    case 'weak-password':
      return WeakPasswordAuthException();
    case 'email-already-in-use':
      return EmailAlreadyInUseAuthException();
    case 'invalid-email':
      return InvalidEmailAuthException();

    // Fallback
    default:
      return GenericAuthException();
  }
}
