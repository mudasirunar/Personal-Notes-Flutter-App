import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/utils/avatar_utils.dart';

void main() {
  group('AvatarUtils - Initials Tests', () {
    test('extracts single initial for single name', () {
      expect(AvatarUtils.getInitials('Anas'), 'A');
      expect(AvatarUtils.getInitials('alice'), 'A');
      expect(AvatarUtils.getInitials('  bob  '), 'B');
    });

    test('extracts first and last initials for two names', () {
      expect(AvatarUtils.getInitials('John Doe'), 'JD');
      expect(AvatarUtils.getInitials('sarah connor'), 'SC');
    });

    test('extracts first and last initials even if more than 2 names', () {
      expect(AvatarUtils.getInitials('Muhammad Anas Khan'), 'MK');
      expect(AvatarUtils.getInitials('Alexander Graham Bell Jr'), 'AJ');
      expect(AvatarUtils.getInitials('Dr. Jane Mary Watson'), 'DW');
    });

    test('falls back to email initial when name is null or empty', () {
      expect(AvatarUtils.getInitials(null, 'test@example.com'), 'T');
      expect(AvatarUtils.getInitials('', 'john@example.com'), 'J');
      expect(AvatarUtils.getInitials('   ', 'alice@test.com'), 'A');
    });

    test('falls back to U when both name and email are empty', () {
      expect(AvatarUtils.getInitials(null, null), 'U');
      expect(AvatarUtils.getInitials('', ''), 'U');
    });
  });

  group('AvatarUtils - Color Tests', () {
    test('defines 24 distinct colors', () {
      expect(AvatarUtils.avatarColors.length, 24);
      final uniqueColors = AvatarUtils.avatarColors.map((c) => c.toARGB32()).toSet();
      expect(uniqueColors.length, 24);
    });

    test('assigns permanent deterministic color for same userId', () {
      final color1 = AvatarUtils.getColorForUser('user_123_abc');
      final color2 = AvatarUtils.getColorForUser('user_123_abc');
      expect(color1, color2);

      final index1 = AvatarUtils.getColorIndex('user_123_abc');
      final index2 = AvatarUtils.getColorIndex('user_123_abc');
      expect(index1, index2);
      expect(index1 >= 0 && index1 < 24, isTrue);
    });

    test('falls back to email if userId is null', () {
      final colorA = AvatarUtils.getColorForUser(null, 'user@test.com');
      final colorB = AvatarUtils.getColorForUser(null, 'user@test.com');
      expect(colorA, colorB);
    });

    test('ensures high contrast readability across all 24 palette colors', () {
      for (final color in AvatarUtils.avatarColors) {
        final textColor = AvatarUtils.getContrastingTextColor(color);
        // Either crisp white or dark slate
        expect(
          textColor == Colors.white || textColor == const Color(0xFF0F172A),
          isTrue,
        );
      }
    });

    test('returns dark text for light backgrounds and white text for dark backgrounds', () {
      expect(AvatarUtils.getContrastingTextColor(Colors.white), const Color(0xFF0F172A));
      expect(AvatarUtils.getContrastingTextColor(Colors.yellow), const Color(0xFF0F172A));
      expect(AvatarUtils.getContrastingTextColor(Colors.black), Colors.white);
      expect(AvatarUtils.getContrastingTextColor(const Color(0xFF4F46E5)), Colors.white);
    });
  });
}
