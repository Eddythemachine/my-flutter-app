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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Enter your email here",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "Password",
                hintText: "Enter your password here",
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
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
                    debugPrint("Error: Wrong password provided for that user.");
                  } else if (e.code == 'invalid-credential') {
                    debugPrint("Error: Invalid email or password.");
                  } else {
                    debugPrint("Firebase Auth Error (${e.code}): ${e.message}");
                  }
                } catch (e) {
                  debugPrint("An unexpected error occurred: $e");
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
