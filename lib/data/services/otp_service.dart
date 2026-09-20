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
  ///
  /// Returns `null` on success, or an error message string on failure.
  static Future<String?> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
  }) async {
    final apiKey = ApiConfig.brevoApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_BREVO_API_KEY_HERE') {
      return 'Brevo API key is not configured. Please set your API key in api_config.dart.';
    }

    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

    final htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password OTP</title>
</head>
<body style="margin: 0; padding: 0; background-color: #f8fafc; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding: 36px 16px;">
    <tr>
      <td align="center">
        <table width="100%" max-width="520px" border="0" cellspacing="0" cellpadding="0" style="max-width: 520px; background-color: #ffffff; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04); overflow: hidden;">
          <!-- Top Accent Bar -->
          <tr>
            <td height="6" style="background: linear-gradient(90deg, #4f46e5, #6366f1, #818cf8);"></td>
          </tr>
          <!-- Body Content -->
          <tr>
            <td style="padding: 36px 32px;">
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding-bottom: 20px;">
                    <h1 style="margin: 0; font-size: 22px; font-weight: 800; color: #0f172a; letter-spacing: -0.5px;">
                      Personal Notes
                    </h1>
                    <p style="margin: 4px 0 0 0; font-size: 13px; color: #64748b; font-weight: 500;">
                      Security Verification
                    </p>
                  </td>
                </tr>
                <tr>
                  <td style="padding-bottom: 16px;">
                    <p style="margin: 0; font-size: 15px; color: #334155; line-height: 1.6;">
                      Hello,
                    </p>
                    <p style="margin: 8px 0 0 0; font-size: 15px; color: #334155; line-height: 1.6;">
                      We received a request to reset your password for your <strong>$recipientEmail</strong> account. Use the verification code below to proceed:
                    </p>
                  </td>
                </tr>
                <!-- OTP Box -->
                <tr>
                  <td align="center" style="padding: 24px 0;">
                    <div style="display: inline-block; background-color: #f1f5f9; border: 2px dashed #cbd5e1; border-radius: 12px; padding: 16px 32px;">
                      <span style="font-family: 'Courier New', Courier, monospace; font-size: 36px; font-weight: 800; letter-spacing: 10px; color: #4f46e5;">
                        $otpCode
                      </span>
                    </div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-top: 8px;">
                    <p style="margin: 0; font-size: 13px; color: #64748b; line-height: 1.5; text-align: center;">
                      ⏱️ This verification code is valid for <strong>10 minutes</strong>.
                    </p>
                    <p style="margin: 12px 0 0 0; font-size: 13px; color: #94a3b8; line-height: 1.5; text-align: center;">
                      If you did not request a password reset, you can safely ignore this email. Your account remains secure.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background-color: #f8fafc; padding: 18px 32px; border-top: 1px solid #f1f5f9; text-align: center;">
              <p style="margin: 0; font-size: 12px; color: #94a3b8;">
                © 2026 Personal Notes App. Automated Security Email.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'api-key': apiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': {
            'name': ApiConfig.brevoSenderName,
            'email': ApiConfig.brevoSenderEmail,
          },
          'replyTo': {
            'name': ApiConfig.brevoSenderName,
            'email': ApiConfig.brevoReplyToEmail,
          },
          'to': [
            {'email': recipientEmail.trim().toLowerCase()}
          ],
          'subject': 'Your Password Reset Code - Personal Notes',
          'htmlContent': htmlContent,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success!
      } else {
        try {
          final data = jsonDecode(response.body);
          return data['message'] ?? 'Failed to send verification email (HTTP ${response.statusCode}).';
        } catch (_) {
          return 'Failed to send verification email (HTTP ${response.statusCode}).';
        }
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
