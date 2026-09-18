import 'package:flutter/material.dart';

enum NoteCategory {
  personal,
  work,
  study;

  String get label {
    switch (this) {
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.work:
        return 'Work';
      case NoteCategory.study:
        return 'Study';
    }
  }

  IconData get icon {
    switch (this) {
      case NoteCategory.personal:
        return Icons.person_outline_rounded;
      case NoteCategory.work:
        return Icons.work_outline_rounded;
      case NoteCategory.study:
        return Icons.menu_book_rounded;
    }
  }

  static NoteCategory fromString(String? value) {
    if (value == null) return NoteCategory.personal;
    switch (value.toLowerCase()) {
      case 'work':
        return NoteCategory.work;
      case 'study':
        return NoteCategory.study;
      case 'personal':
      default:
        return NoteCategory.personal;
    }
  }
}

class AppConstants {
  static const String appName = 'Personal Notes';

  // Validation Limits
  static const int minPasswordLength = 8;
  static const int minTitleLength = 1;
  static const int maxTitleLength = 80;
  static const int minContentLength = 1;
  static const int maxContentLength = 2000;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String notesSubcollection = 'notes';
}
