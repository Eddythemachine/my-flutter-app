import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/constants/routes.dart';

/// 🧭 Decide where the user should really be, or `null` to allow the
/// requested route through.
String? authRedirect(String? requestedRoute) {
  final user = FirebaseAuth.instance.currentUser;
  final loggedIn = user != null;
  final verified = user?.emailVerified ?? false;

  // Not logged in → only login/register are allowed
  if (!loggedIn) {
    if (requestedRoute == loginRoute || requestedRoute == registerRoute) {
      return null; // allow
    }
    return loginRoute;
  }

  // Logged in but not verified → only verify-email is allowed
  if (!verified) {
    if (requestedRoute == verifyEmailRoute) {
      return null; // allow
    }
    return verifyEmailRoute;
  }

  // Logged in and verified → block login/register/verify, send to notes
  if (requestedRoute == loginRoute ||
      requestedRoute == registerRoute ||
      requestedRoute == verifyEmailRoute) {
    return notesRoute;
  }
  return null;
}
