// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette ─────────────────────────────────────────────────────────────
  static const Color bg        = Color(0xFF0A0A0F);  // near-black
  static const Color surface   = Color(0xFF13131A);  // card bg
  static const Color surfaceHi = Color(0xFF1C1C27);  // slightly lighter
  static const Color accent    = Color(0xFFFF3D6B);  // hot pink-red
  static const Color accentLo  = Color(0x33FF3D6B);  // translucent accent
  static const Color textHi    = Color(0xFFF0F0F5);
  static const Color textMid   = Color(0xFF9090A8);
  static const Color textLo    = Color(0xFF44445A);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: accent,
      secondary: accent,
      onPrimary: Colors.white,
      onSurface: textHi,
    ),

    // ── AppBar ─────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textHi,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textHi),
    ),

    // ── Input ──────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHi,
      hintStyle: const TextStyle(color: textMid, fontSize: 15),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),

    // ── Elevated button ────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ── Progress indicator ─────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: accentLo,
    ),

    // ── Text ───────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: textHi,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        color: textHi,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(color: textMid, fontSize: 13),
      bodySmall: TextStyle(color: textLo, fontSize: 11),
    ),

    dividerTheme: const DividerThemeData(
      color: surfaceHi,
      thickness: 1,
      space: 0,
    ),
  );
}