import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/main.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // ✅ Controllers belong in the State class
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    // ✅ Always dispose controllers to prevent memory leaks
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
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

                        debugPrint("Email: $email | Password: $password");

                        try {
                          final userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                          debugPrint("Success: ${userCredential.user?.email}");
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
                      child: const Text("Register"),
                    ),
                  ],
                ),
              );
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
