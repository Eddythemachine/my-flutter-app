import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/constants/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, loginRoute);
      });
      return const SizedBox.shrink();
    }

    return Material(
      child: Container(
        // 🎨 Using the shared gradient
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎨 Using a larger variation of the title text style
                Text(
                  "iNote Dashboard",
                  style: AppTheme.title.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  // 🎨 Using the shared card radius and shadow
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        user.emailVerified
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        size: 48,
                        // 🎨 Using shared colors
                        color: user.emailVerified
                            ? AppTheme.deep
                            : AppTheme.warning,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.emailVerified
                            ? "User is verified ✅"
                            : "You need to verify your email ❌",
                        // 🎨 Using shared text colors
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
