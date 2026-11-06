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
                  color: Colors.white.withOpacity(0.92),
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
                  style: const TextStyle(color: Color(0xFF0F2027)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF134E5E),
                    ),
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.black54),
                    hintText: "Enter your email",
                    hintStyle: const TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
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
                  color: Colors.white.withOpacity(0.92),
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
                  style: const TextStyle(color: Color(0xFF0F2027)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF134E5E),
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
              const SizedBox(height: 28),

              // Animated Login Button
              GestureDetector(
                onTapDown: (_) => setState(() => _buttonScale = 0.95),
                onTapUp: (_) => setState(() => _buttonScale = 1.0),
                onTapCancel: () => setState(() => _buttonScale = 1.0),
                onTap: () async {
                  final email = _email.text.trim();
                  final password = _password.text.trim();

                  try {
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                    debugPrint("Success: ${userCredential.user?.email}");
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      debugPrint("Error: No user found for that email.");
                    } else if (e.code == 'wrong-password') {
                      debugPrint(
                        "Error: Wrong password provided for that user.",
                      );
                    } else if (e.code == 'invalid-credential') {
                      debugPrint("Error: Invalid email or password.");
                    } else {
                      debugPrint(
                        "Firebase Auth Error (${e.code}): ${e.message}",
                      );
                    }
                  } catch (e) {
                    debugPrint("An unexpected error occurred: $e");
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
                  Navigator.pushReplacementNamed(context, "/register/");
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
