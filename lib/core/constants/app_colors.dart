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

  // ---------------------------------------------------------------------------
  // Dark Theme Palette
  // ---------------------------------------------------------------------------
  static const Color scaffoldBackgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color cardSurfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color inputFillDark = Color(0xFF1E293B); // Slate 800

  // Dark Borders
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color borderFocusedDark = Color(0xFF818CF8); // Indigo 400

  // Dark Typography (High-contrast, eye-friendly readability)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Dark Semantic
  static const Color errorDark = Color(0xFFF87171); // Red 400
  static const Color errorLightDark = Color(0x33DC2626); // Red 600 with opacity

  // Dark Shimmer
  static const Color shimmerBaseDark = Color(0xFF1E293B);
  static const Color shimmerHighlightDark = Color(0xFF334155);

  // ---------------------------------------------------------------------------
  // Context-Aware Helpers for Dynamic Theme Adaptation
  // ---------------------------------------------------------------------------
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffoldBackgroundOf(BuildContext context) =>
      isDark(context) ? scaffoldBackgroundDark : scaffoldBackground;

  static Color cardSurfaceOf(BuildContext context) =>
      isDark(context) ? cardSurfaceDark : cardSurface;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? borderDark : border;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? textMutedDark : textMuted;

  static Color inputFillOf(BuildContext context) =>
      isDark(context) ? inputFillDark : inputFill;

  static Color shimmerBaseOf(BuildContext context) =>
      isDark(context) ? shimmerBaseDark : shimmerBase;
}
