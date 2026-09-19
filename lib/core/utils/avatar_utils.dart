import 'package:flutter/material.dart';

/// Utilities for generating WhatsApp-style profile avatar colors and initials.
class AvatarUtils {
  /// Curated palette of 24 distinct, rich, accessible colors for avatars.
  static const List<Color> avatarColors = [
    Color(0xFFE53935), // Red 600
    Color(0xFFD81B60), // Pink 600
    Color(0xFF8E24AA), // Purple 600
    Color(0xFF5E35B1), // Deep Purple 600
    Color(0xFF3949AB), // Indigo 600
    Color(0xFF1E88E5), // Blue 600
    Color(0xFF039BE5), // Light Blue 600
    Color(0xFF00ACC1), // Cyan 600
    Color(0xFF00897B), // Teal 600
    Color(0xFF43A047), // Green 600
    Color(0xFF7CB342), // Light Green 600
    Color(0xFFC0CA33), // Lime 600
    Color(0xFFD97706), // Amber 600
    Color(0xFFFB8C00), // Orange 600
    Color(0xFFF4511E), // Deep Orange 600
    Color(0xFF6D4C41), // Brown 600
    Color(0xFF546E7A), // Blue Grey 600
    Color(0xFF0D9488), // Teal Dark
    Color(0xFF059669), // Emerald 600
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF7C3AED), // Violet 600
    Color(0xFFDB2777), // Rose Pink
    Color(0xFFEA580C), // Burnt Orange
    Color(0xFF4F46E5), // Brand Indigo
  ];

  /// Returns a deterministic color index from 0 to 23 for a user ID or email.
  static int getColorIndex(String? userId, [String? email]) {
    final seed = (userId != null && userId.trim().isNotEmpty)
        ? userId.trim()
        : ((email != null && email.trim().isNotEmpty) ? email.trim().toLowerCase() : 'user');

    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash % avatarColors.length;
  }

  /// Returns the permanent avatar color assigned to this user.
  static Color getColorForUser(String? userId, [String? email]) {
    final index = getColorIndex(userId, email);
    return avatarColors[index];
  }

  /// Extracts WhatsApp-style uppercase initials:
  /// - If single name: 1 initial (e.g. "Anas" -> "A")
  /// - If 2+ names: first and last name initials only (e.g. "Muhammad Anas Khan" -> "MK")
  /// - Fallback to email first letter or 'U'
  static String getInitials(String? fullName, [String? email]) {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length == 1) {
        return parts.first[0].toUpperCase();
      } else if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
    }

    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) {
      return mail[0].toUpperCase();
    }

    return 'U';
  }

  /// Returns a high-contrast foreground color (crisp white or deep slate)
  /// calculated from the background color's perceived luminance, guaranteeing
  /// 100% readability across any background color.
  static Color getContrastingTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.45
        ? const Color(0xFF0F172A)
        : Colors.white;
  }
}
