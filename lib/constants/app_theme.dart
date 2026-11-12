import 'package:flutter/material.dart';

/// 🎨 Central place for every color, gradient, and text style.
/// Change a value here and the whole app updates automatically.
class AppTheme {
  AppTheme._();

  // ───────── Colors ─────────
  static const Color primary = Color(0xFF64FFDA); // Mint accent
  static const Color dark = Color(0xFF0F2027); // Near-black
  static const Color mid = Color(0xFF203A43); // Slate
  static const Color deep = Color(0xFF134E5E); // Teal
  static const Color surface = Colors.white; // Card background
  static const Color textOnSurface = Color(0xFF0F2027);
  static const Color muted = Colors.white70;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orangeAccent;

  // ───────── Gradients ─────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark, mid, deep],
  );

  // ───────── Radii ─────────
  static const double radiusField = 12;
  static const double radiusCard = 16;
  static const double radiusBanner = 8;

  // ───────── Shadows ─────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
  ];
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
  ];

  // ───────── Text Styles ─────────
  static const TextStyle title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 2,
    shadows: [
      Shadow(blurRadius: 12.0, color: Colors.black54, offset: Offset(2, 2)),
    ],
  );

  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primary,
    letterSpacing: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: muted,
    height: 1.4,
  );

  static const TextStyle buttonLabel = TextStyle(
    color: dark,
    fontWeight: FontWeight.bold,
    fontSize: 17,
    letterSpacing: 1,
  );

  // ───────── MaterialApp Theme ─────────
  static ThemeData get materialTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: deep, primary: primary),
    useMaterial3: true,
  );
}
