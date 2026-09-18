import 'package:firebase_auth/firebase_auth.dart';

class ErrorMapper {
  /// Maps Firebase Authentication errors to clear, friendly user messages.
  static String mapAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or tap "Forgot Password".';
        case 'invalid-credential':
          return 'Invalid email or password. Please verify your credentials.';
        case 'email-already-in-use':
          return 'An account with this email already exists. Please sign in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a password with at least 8 characters.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Access has been temporarily paused for your security. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is currently not enabled in the Firebase Console.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    final message = error.toString();
    if (message.contains('network-request-failed') || message.contains('unavailable')) {
      return 'Network connection issue. Please check your internet connection.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again in a few minutes.';
    }

    return 'Authentication error occurred. Please try again.';
  }

  /// Maps Cloud Firestore errors to friendly user messages.
  static String mapFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. You only have permission to view your own notes.';
        case 'unavailable':
        case 'deadline-exceeded':
          return 'Server connection timed out. Please check your internet connection.';
        case 'not-found':
          return 'The requested note could not be found.';
        default:
          return error.message ?? 'A database error occurred. Please try again.';
      }
    }

    final message = error.toString();
    if (message.contains('permission-denied')) {
      return 'Access denied. You only have permission to view your own notes.';
    } else if (message.contains('unavailable') || message.contains('network')) {
      return 'Network connection issue. Please check your internet connection.';
    }

    return 'Unable to complete note operation. Please try again.';
  }
}
