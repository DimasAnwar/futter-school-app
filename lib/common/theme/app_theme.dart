import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2563EB),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      canvasColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
      ),
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      dividerColor: const Color(0xFFE2E8F0),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF3B82F6),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      canvasColor: const Color(0xFF1E293B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        surface: Color(0xFF1E293B),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1E293B),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1E293B),
      ),
      dividerColor: const Color(0xFF334155),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E293B),
      ),
    );
  }
}
