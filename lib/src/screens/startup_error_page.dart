import 'package:flutter/material.dart';

/// Firebase failed to initialise before the app could start.
class FirebaseInitError {
  const FirebaseInitError(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

/// Shown instead of the app when Firebase cannot be initialised, so the user
/// gets an explanation rather than a blank screen.
class StartupErrorPage extends StatelessWidget {
  const StartupErrorPage({super.key, required this.error});

  final FirebaseInitError error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: scheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Couldn't start iNote",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Firebase could not be initialised. Check your internet '
                    'connection, your firebase_options.dart values, and that '
                    'the Firebase project is still active — then restart the app.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer.withAlpha(90),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.error.withAlpha(70)),
                    ),
                    child: SelectableText(
                      error.error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
