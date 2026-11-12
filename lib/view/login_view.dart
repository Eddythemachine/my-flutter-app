import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF134E5E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "iNote",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64FFDA),
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      blurRadius: 12.0,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Styled Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      if (mounted) setState(() => _errorMessage = null);
                    }
                  },
                  style: const TextStyle(color: Color(0xFF0F2027)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color(0xFF134E5E),
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
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      if (mounted) setState(() => _errorMessage = null);
                    }
                  },
                  style: const TextStyle(color: Color(0xFF0F2027)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xFF134E5E),
                    ),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.black54),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
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
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
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

              // Animated Login Button with properly nested GestureDetector and AnimatedScale
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
                onTap: () async {
                  final email = _email.text.trim();
                  final password = _password.text.trim();

                  if (mounted) setState(() => _errorMessage = null);

                  try {
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                    debugPrint("Success: ${userCredential.user?.email}");

                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/notes/',
                      (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      setState(() {
                        if (e.code == 'user-not-found' ||
                            e.code == 'invalid-credential') {
                          _errorMessage =
                              "No account found or invalid credentials.";
                        } else if (e.code == 'wrong-password') {
                          _errorMessage =
                              "Incorrect password provided. Try again.";
                        } else if (e.code == 'invalid-email') {
                          _errorMessage =
                              "The email address format is invalid.";
                        } else {
                          _errorMessage = "Authentication failed: ${e.message}";
                        }

                        // Automatically clear password so they don't have to backspace from scratch
                        _password.clear();
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _errorMessage = "An unexpected error occurred: $e";
                        _password.clear();
                      });
                    }
                  }
                },
                child: AnimatedScale(
                  scale: _buttonScale,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64FFDA),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF0F2027),
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/register/',
                    (route) => false,
                  );
                },
                child: const Text(
                  "Not registered yet? Register here!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
