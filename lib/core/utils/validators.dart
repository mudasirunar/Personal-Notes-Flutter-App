import '../constants/app_constants.dart';

class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateNoteTitle(String? value) {
    if (value == null) {
      return 'Title is required';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Title cannot be empty or whitespace only';
    }
    if (trimmed.length > AppConstants.maxTitleLength) {
      return 'Title must be ${AppConstants.maxTitleLength} characters or less';
    }
    return null;
  }

  static String? validateNoteContent(String? value) {
    if (value == null) {
      return 'Content is required';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Content cannot be empty or whitespace only';
    }
    if (trimmed.length > AppConstants.maxContentLength) {
      return 'Content must be ${AppConstants.maxContentLength} characters or less';
    }
    return null;
  }
}
