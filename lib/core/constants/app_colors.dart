import 'package:flutter/material.dart';

/// Single source of truth for all application colors.
/// Adheres to a minimal, modern, and professional aesthetic without flashy neon or heavy gradients.
class AppColors {
  // Brand & Neutrals
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color accent = Color(0xFF4F46E5); // Indigo 600
  static const Color accentLight = Color(0xFFEEF2FF); // Indigo 50

  static const Color scaffoldBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color cardSurface = Colors.white;
  static const Color inputFill = Color(0xFFF8FAFC);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocused = Color(0xFF4F46E5);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Semantic Colors
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEF2F2); // Red 50
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successLight = Color(0xFFF0FDF4); // Green 50

  // Favorites
  static const Color favorite = Color(0xFFEAB308); // Yellow 500
  static const Color favoriteInactive = Color(0xFFCBD5E1); // Slate 300

  // Category Tints
  static const Color categoryPersonal = Color(0xFF4F46E5); // Indigo
  static const Color categoryPersonalBg = Color(0xFFEEF2FF);

  static const Color categoryWork = Color(0xFFD97706); // Amber 600
  static const Color categoryWorkBg = Color(0xFFFFFBEB);

  static const Color categoryStudy = Color(0xFF059669); // Emerald 600
  static const Color categoryStudyBg = Color(0xFFECFDF5);

  // Shimmer / Skeleton
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
