import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF0A8F67);
  static const greenDark = Color(0xFF087455);
  static const greenSoft = Color(0xFFEAF7F0);
  static const ink = Color(0xFF1C2933);
  static const muted = Color(0xFF6E7C86);
  static const line = Color(0xFFE4E9EC);
  static const surface = Color(0xFFF7FAF9);
  static const lavender = Color(0xFFEDE9FF);
  static const yellow = Color(0xFFFFF4D7);
  static const pink = Color(0xFFFDECEF);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
    ),
    fontFamily: 'Arial',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
    ),
  );
}
