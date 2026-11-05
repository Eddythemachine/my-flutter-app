import 'package:flutter/material.dart';

import 'src/screens/auth_gate.dart';
import 'src/screens/startup_error_page.dart';
import 'src/theme/app_theme.dart';

/// Root widget: theme + navigation entry point.
class INoteApp extends StatelessWidget {
  const INoteApp({super.key, this.initError});

  /// Non-null when Firebase failed to initialise inside `main()`.
  final FirebaseInitError? initError;

  @override
  Widget build(BuildContext context) {
    final error = initError;

    return MaterialApp(
      title: 'iNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: error == null ? const AuthGate() : StartupErrorPage(error: error),
    );
  }
}
