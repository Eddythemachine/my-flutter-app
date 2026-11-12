import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/constants/app_theme.dart'; // 👈 Added import
import 'package:flutter_application_1/constants/auth_redirect.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/notes/note.dart';
import 'package:flutter_application_1/view/home_page.dart';
import 'package:flutter_application_1/view/login_view.dart';
import 'package:flutter_application_1/view/register_view.dart';
import 'package:flutter_application_1/view/verify_email_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      title: 'iNote',
      debugShowCheckedModeBanner: false,
      // 👇 Replaced the inline ThemeData with our central theme
      theme: AppTheme.materialTheme,
      initialRoute: loginRoute,
      onGenerateRoute: (settings) {
        // 🔐 Redirect based on auth + verification state
        final redirect = authRedirect(settings.name);
        if (redirect != null) {
          return _buildRoute(RouteSettings(name: redirect));
        }

        return _buildRoute(settings);
      },
    ),
  );
}

/// 🏗️ Builds a route with the slide-up + fade transition.
PageRouteBuilder _buildRoute(RouteSettings settings) {
  Widget page;
  switch (settings.name) {
    case loginRoute:
      page = const LoginView();
      break;
    case registerRoute:
      page = const RegisterView();
      break;
    case verifyEmailRoute:
      page = const VerifyEmailView();
      break;
    case homeRoute:
      page = const HomePage();
      break;
    case notesRoute:
      page = const NotesView();
      break;
    default:
      page = const LoginView();
  }

  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.08);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
