import 'package:flutter/material.dart';

/// Single source of truth for the iNote look: a warm Material 3 red.
///
/// Only stable theme classes are used here (no `InputDecorationTheme`,
/// `CardTheme`, ...) so the file keeps compiling across Flutter releases.
abstract final class AppTheme {
  /// Material red 700 — the brand colour.
  static const Color seed = Color(0xFFD32F2F);

  /// Corner radius shared by inputs, buttons and cards.
  static const double radius = 16;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      // A raw seed produces a pink-ish primary; pin the real brand red instead.
      primary: isDark ? const Color(0xFFFF7169) : seed,
      onPrimary: isDark ? const Color(0xFF3A0907) : Colors.white,
      secondary: isDark ? const Color(0xFFE57373) : const Color(0xFFB71C1C),
      surface: isDark ? const Color(0xFF141212) : const Color(0xFFFFFBFA),
      onSurface: isDark ? const Color(0xFFF4E9E7) : const Color(0xFF201A19),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );

    final textTheme = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withAlpha(110),
          disabledForegroundColor: scheme.onPrimary.withAlpha(180),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2C2727) : const Color(0xFF322D2C),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: isDark ? const Color(0xFFFFB4AE) : const Color(0xFFFFDAD6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      dividerTheme: DividerThemeData(color: scheme.outline.withAlpha(60)),
    );
  }
}
