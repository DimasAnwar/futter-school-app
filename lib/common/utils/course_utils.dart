import 'package:flutter/material.dart';

class CourseUtils {
  /// Returns an appropriate IconData based on the course name keywords.
  static IconData getIconForCourse(String courseName) {
    final lower = courseName.toLowerCase();
    if (lower.contains('fisika') || lower.contains('kimia') || lower.contains('sains')) {
      return Icons.science_outlined;
    }
    if (lower.contains('program') ||
        lower.contains('web') ||
        lower.contains('komputer') ||
        lower.contains('algoritma') ||
        lower.contains('perangkat lunak')) {
      return Icons.code_rounded;
    }
    if (lower.contains('matematika') || lower.contains('kalkulus') || lower.contains('statistik')) {
      return Icons.calculate_outlined;
    }
    if (lower.contains('inggris') || lower.contains('bahasa')) {
      return Icons.translate_rounded;
    }
    if (lower.contains('basis data') || lower.contains('database')) {
      return Icons.storage_rounded;
    }
    return Icons.grid_view_rounded;
  }
}
