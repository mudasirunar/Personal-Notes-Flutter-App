import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../core/constants/api_config.dart';

class OtpService {
  /// Generates a cryptographically secure, random 6-digit numeric OTP (100000 - 999999)
  static String generateOtp() {
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Sends a formatted HTML email containing the 6-digit OTP via Brevo's REST API.
  /// Returns `null` on success, or an error message string on failure.
  static Future<String?> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
  }) async {
    final backendUrl = ApiConfig.backendSendOtpUrl;
    if (backendUrl.isEmpty) {
      return 'Send OTP backend URL is not configured.';
    }

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': recipientEmail.trim().toLowerCase(),
          'otpCode': otpCode,
          'secretToken': ApiConfig.resetSecretToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return null; // Success!
      } else {
        return data['error'] ?? 'Failed to send verification email.';
      }
    } catch (e) {
      return 'Network error sending verification code: $e';
    }
  }

  /// Calls the Vercel backend serverless endpoint to update the user's password in Firebase.
  ///
  /// Returns `null` on success, or an error message string on failure.
  static Future<String?> updatePasswordViaBackend({
    required String email,
    required String newPassword,
  }) async {
    final backendUrl = ApiConfig.backendResetPasswordUrl;
    if (backendUrl.isEmpty || backendUrl.contains('your-backend-domain')) {
      return 'Backend URL is not configured. Please set your Vercel URL in api_config.dart.';
    }

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'newPassword': newPassword,
          'secretToken': ApiConfig.resetSecretToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return null; // Success!
      } else {
        return data['error'] ?? 'Failed to update password. Please try again.';
      }
    } catch (e) {
      return 'Network error communicating with password update service: $e';
    }
  }
}
