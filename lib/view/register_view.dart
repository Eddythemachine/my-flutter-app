import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/constants/app_theme.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_exceptions.dart';
import 'package:flutter_application_1/services/auth/auth_error_translator.dart';
import 'package:flutter_application_1/utils/verification_cooldown.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  double _buttonScale = 1.0;
  String? _errorMessage;
  String? _emailError;
  bool _obscurePassword = true;

  // Password strength state
  String _passwordStrengthText = "";
  Color _passwordStrengthColor = Colors.transparent;
  double _passwordStrengthProgress = 0.0;

  // Simple RFC-ish email pattern
  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$',
  );

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // 🔍 Real-time password evaluation
  void _evaluatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrengthText = "";
        _passwordStrengthColor = Colors.transparent;
        _passwordStrengthProgress = 0.0;
      });
      return;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );
    bool isLongEnough = password.length >= 8;

    int score = 0;
    if (password.length >= 6) score++;
    if (hasUppercase) score++;
    if (hasDigits) score++;
    if (hasSpecialCharacters) score++;
    if (isLongEnough) score++;

    setState(() {
      if (password.length < 6 || score <= 1) {
        _passwordStrengthText = "Too weak";
        _passwordStrengthColor = AppTheme.error; // 👈 Using theme error color
        _passwordStrengthProgress = 0.25;
      } else if (score == 2 || score == 3) {
        _passwordStrengthText = "Medium strength";
        _passwordStrengthColor =
            AppTheme.warning; // 👈 Using theme warning color
        _passwordStrengthProgress = 0.6;
      } else {
        _passwordStrengthText = "Strong password!";
        _passwordStrengthColor =
            AppTheme.primary; // 👈 Using theme primary color
        _passwordStrengthProgress = 1.0;
      }
    });
  }

  // 📧 Instant email format check
  void _onEmailChanged(String value) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    final email = value.trim();

    setState(() {
      if (email.isEmpty) {
        _emailError = null;
      } else if (!_emailRegExp.hasMatch(email)) {
        _emailError = "Invalid email format";
      } else {
        _emailError = null;
      }
    });
  }

  // 🚀 Extracted registration logic
  Future<void> _register() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    // Block submit if format is invalid
    if (_emailError != null) {
      if (mounted) setState(() => _errorMessage = _emailError);
      return;
    }

    if (mounted) setState(() => _errorMessage = null);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      debugPrint("Success: ${userCredential.user?.email}");

      // Send verification email (respecting cooldown)
      if (VerificationCooldown.canSend) {
        try {
          await userCredential.user?.sendEmailVerification();
          VerificationCooldown.markSent();
        } catch (sendError) {
          debugPrint("Could not send verification email: $sendError");
        }
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        verifyEmailRoute,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // 🛡️ Translate Firebase error into our custom exceptions
      final customError = translateAuthException(e);

      if (!mounted) return;
      setState(() {
        if (customError is WeakPasswordAuthException) {
          _errorMessage = "The password provided is too weak.";
        } else if (customError is EmailAlreadyInUseAuthException) {
          _errorMessage = "An account already exists for that email.";
        } else if (customError is InvalidEmailAuthException) {
          _errorMessage = "The email address is badly formatted.";
        } else {
          _errorMessage = "Registration failed. Please try again.";
        }

        _password.clear();
        _passwordStrengthText = "";
        _obscurePassword = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "An unexpected error occurred: $e";
        _password.clear();
        _passwordStrengthText = "";
        _obscurePassword = true;
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
                  const Text("Create Account", style: AppTheme.title),
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
                      onChanged: _onEmailChanged,
                      style: const TextStyle(color: AppTheme.textOnSurface),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppTheme.deep,
                        ),
                        suffixIcon: _emailError != null
                            ? const Icon(
                                Icons.error_outline,
                                color: AppTheme.error,
                              )
                            : null,
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.black54),
                        hintText: "Enter your email here",
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  // Short inline message under the email field
                  if (_emailError != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.error,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                color: AppTheme.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          if (mounted) setState(() => _errorMessage = null);
                        }
                        _evaluatePasswordStrength(value);
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
                        hintText: "Enter your password here",
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  // Real-Time Password Strength Indicator
                  if (_passwordStrengthText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Password Strength:",
                                style: TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _passwordStrengthText,
                                style: TextStyle(
                                  color: _passwordStrengthColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrengthProgress,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _passwordStrengthColor,
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Fancy Inline Error Banner
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
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

                  // Animated Register Button
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
                    onTap: _register,
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
                        child: const Text(
                          "Register",
                          style: AppTheme.buttonLabel,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        loginRoute,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Already registered? Login here!",
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
