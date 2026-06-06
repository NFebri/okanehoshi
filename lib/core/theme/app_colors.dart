import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color accent = Color(0xFF10B981); // Emerald Green for transaction success

  // Theme-specific Backgrounds
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color bgDark = Color(0xFF0F172A); // Slate 900

  // Card backgrounds
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B); // Slate 800

  // Text colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50

  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // Status/Alert Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Miscellaneous
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color shadowLight = Color(0x0F000000);
}
