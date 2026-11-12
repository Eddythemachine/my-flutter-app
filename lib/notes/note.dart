import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:developer' as devtools show log;

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F2027).withValues(alpha: 0.8),
            elevation: 0,
            title: const Text(
              "iNote Dashboard",
              style: TextStyle(
                color: Color(0xFF64FFDA),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF64FFDA)),
            actions: [
              PopupMenuButton<MenuAction>(
                color: const Color(0xFF203A43),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      devtools.log("Logout menu selected");
                      final shouldLogOut = await showLogOutDialog(context);
                      devtools.log("User confirmed logout: $shouldLogOut");

                      if (shouldLogOut) {
                        // 1. Sign out the user from Firebase Auth
                        await FirebaseAuth.instance.signOut();
                        devtools.log("User signed out successfully");

                        // 2. Check if the widget is still mounted before using the context
                        if (!context.mounted) return;

                        // 3. Wipes the navigation stack and sends them back to the login screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login/',
                          (route) => false,
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Color(0xFF64FFDA),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: const Center(
            child: Text(
              "Welcome to your Notes View!",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Sign out",
          style: TextStyle(
            color: Color(0xFF64FFDA),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to sign out?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              "Log out",
              style: TextStyle(
                color: Color(0xFF64FFDA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
