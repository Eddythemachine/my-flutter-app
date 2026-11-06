import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // ✅ Controllers belong in the State class
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  // Scale state variable for the button animation
  double _buttonScale = 1.0;

  @override
  void dispose() {
    // ✅ Always dispose controllers to prevent memory leaks
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
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64FFDA),
                          letterSpacing: 2,
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color(0xFF134E5E),
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: "Enter your email here",
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color(0xFF134E5E),
                            ),
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: "Enter your password here",
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Animated Register Button
                      GestureDetector(
                        onTapDown: (_) => setState(() => _buttonScale = 0.95),
                        onTapUp: (_) => setState(() => _buttonScale = 1.0),
                        onTapCancel: () => setState(() => _buttonScale = 1.0),
                        onTap: () async {
                          final email = _email.text.trim();
                          final password = _password.text.trim();

                          debugPrint("Email: $email | Password: $password");

                          try {
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                            debugPrint(
                              "Success: ${userCredential.user?.email}",
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              debugPrint(
                                "Error: The password provided is too weak.",
                              );
                            } else if (e.code == 'email-already-in-use') {
                              debugPrint(
                                "Error: An account already exists for that email.",
                              );
                            } else if (e.code == 'invalid-email') {
                              debugPrint(
                                "Error: The email address is badly formatted.",
                              );
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
                              "Register",
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
                          Navigator.pushReplacementNamed(context, "/login/");
                        },
                        child: const Text(
                          "Already registered? Login here!",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              default:
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF64FFDA)),
                );
            }
          },
        ),
      ),
    );
  }
}
