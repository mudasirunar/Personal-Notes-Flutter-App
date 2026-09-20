/// Centralized configuration for third-party external services (Brevo & Backend).
///
/// NOTE: Replace [brevoApiKey] with your actual API key from https://brevo.com.
/// Replace [backendResetPasswordUrl] with your deployed Vercel URL.
class ApiConfig {
  /// Brevo API Key from https://app.brevo.com/settings/keys/api
  /// Brevo API Key is now safely managed on your Vercel backend environment variables:
  /// (BREVO_API_KEY) so GitHub/scanners never see or revoke it.
  static const String backendSendOtpUrl = String.fromEnvironment(
    'BACKEND_SEND_OTP_URL',
    defaultValue: 'https://personal-notes-flutter-app.vercel.app/api/send-otp',
  );

  /// Verified sender email in your Brevo account (unarmudasir@gmail.com)
  static const String brevoSenderEmail = String.fromEnvironment(
    'BREVO_SENDER_EMAIL',
    defaultValue: 'unarmudasir@gmail.com',
  );

  /// Sender display name for emails (prominently visible in inbox)
  static const String brevoSenderName = 'Personal Notes Support';

  /// Reply-To email address
  static const String brevoReplyToEmail = 'support@personalnotes.app';

  /// Your deployed Vercel serverless function URL
  static const String backendResetPasswordUrl = String.fromEnvironment(
    'BACKEND_RESET_PASSWORD_URL',
    defaultValue:
        'https://personal-notes-flutter-app.vercel.app/api/reset-password',
  );

  /// Shared secret token matching RESET_SECRET_TOKEN in backend environment
  static const String resetSecretToken = 'personal_notes_secret_token_2026';
}
