/// Centralized configuration for third-party external services (Brevo & Backend).
///
/// NOTE: Replace [brevoApiKey] with your actual API key from https://brevo.com.
/// Replace [backendResetPasswordUrl] with your deployed Vercel URL.
class ApiConfig {
  /// Brevo API Key from https://app.brevo.com/settings/keys/api
  static const String brevoApiKey = String.fromEnvironment(
    'BREVO_API_KEY',
    defaultValue:
        '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',
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
  /// Example: https://personal-notes-backend.vercel.app/api/reset-password
  static const String backendResetPasswordUrl = String.fromEnvironment(
    'BACKEND_RESET_PASSWORD_URL',
    defaultValue: 'https://personal-notes-backend.vercel.app/api/reset-password',
  );

  /// Shared secret token matching RESET_SECRET_TOKEN in backend environment
  static const String resetSecretToken = 'personal_notes_secret_token_2026';
}
