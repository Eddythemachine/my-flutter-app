import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/brand_mark.dart';
import 'auth_page.dart';
import 'home_page.dart';

/// Decides between the auth screen and the signed-in home screen.
///
/// Previously the auth form *was* the home page and nothing listened to the
/// auth state, so a successful sign-in left you on the form. `authStateChanges()`
/// keeps the UI in sync automatically — including after a hot restart.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _auth = AuthService();

  // Created once. Building the stream inside build() would resubscribe on every
  // rebuild and make the screen flicker back to the splash.
  late final Stream<User?> _userChanges = _auth.authStateChanges;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }

        final user = snapshot.data;
        if (user == null) {
          return const AuthPage();
        }

        return HomePage(user: user, onSignOut: _auth.signOut);
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 84),
            const SizedBox(height: 24),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
