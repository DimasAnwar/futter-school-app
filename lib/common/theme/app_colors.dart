import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static Color textMuted(BuildContext context) =>
      isDark(context) ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  static Color bgScaffold(BuildContext context) =>
      isDark(context) ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  static Color bgCard(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E293B) : Colors.white;

  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
}
