import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/constants/app_theme.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_exceptions.dart';
import 'package:flutter_application_1/services/auth/auth_error_translator.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  double _buttonScale = 1.0;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (mounted) setState(() => _errorMessage = null);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint("Success: ${userCredential.user?.email}");

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, notesRoute, (route) => false);
    } on FirebaseAuthException catch (e) {
      // 🛡️ Translate Firebase error into our custom exceptions
      final customError = translateAuthException(e);

      if (!mounted) return;
      setState(() {
        if (customError is UserNotFoundAuthException) {
          _errorMessage = "No account found or invalid credentials.";
        } else if (customError is WrongPasswordAuthException) {
          _errorMessage = "Incorrect password provided. Try again.";
        } else if (customError is InvalidEmailAuthException) {
          _errorMessage = "The email address format is invalid.";
        } else {
          _errorMessage = "Authentication failed. Please try again.";
        }

        _password.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "An unexpected error occurred: $e";
        _password.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        // 🎨 Shared background gradient
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🎨 Shared text style
                  const Text("iNote", style: AppTheme.title),
                  const SizedBox(height: 36),

                  // Styled Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          if (mounted) setState(() => _errorMessage = null);
                        }
                      },
                      style: const TextStyle(color: AppTheme.textOnSurface),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppTheme.deep,
                        ),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter your email",
                        hintStyle: TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Styled Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TextField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          if (mounted) setState(() => _errorMessage = null);
                        }
                      },
                      style: const TextStyle(color: AppTheme.textOnSurface),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.deep,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.deep,
                          ),
                          tooltip: _obscurePassword
                              ? "Show password"
                              : "Hide password",
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.black54),
                        hintText: "Enter your password",
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  // Inline Fancy Error Banner
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusBanner,
                        ),
                        border: Border.all(color: AppTheme.error, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Animated Login Button
                  GestureDetector(
                    onTapDown: (_) {
                      if (mounted) setState(() => _buttonScale = 0.95);
                    },
                    onTapUp: (_) {
                      if (mounted) setState(() => _buttonScale = 1.0);
                    },
                    onTapCancel: () {
                      if (mounted) setState(() => _buttonScale = 1.0);
                    },
                    onTap: _login,
                    child: AnimatedScale(
                      scale: _buttonScale,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusField,
                          ),
                          boxShadow: AppTheme.buttonShadow,
                        ),
                        alignment: Alignment.center,
                        child: const Text("Login", style: AppTheme.buttonLabel),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        registerRoute,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Not registered yet? Register here!",
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
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
