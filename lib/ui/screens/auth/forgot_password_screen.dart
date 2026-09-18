import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  String? _sentToEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final success = await authProvider.sendPasswordResetEmail(email: email);

    if (success && mounted) {
      setState(() {
        _emailSent = true;
        _sentToEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundOf(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            authProvider.clearError();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _emailSent
                  ? _buildSuccessView(context)
                  : _buildRequestForm(context, authProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context, AuthProvider authProvider) {
    final isDark = AppColors.isDark(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password',
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email associated with your account and we’ll send you instructions to reset your password.',
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Error Banner
          if (authProvider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.errorLightDark : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isDark ? AppColors.errorDark : AppColors.error).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: isDark ? AppColors.errorDark : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: isDark ? AppColors.errorDark : AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Email Field
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            validator: Validators.validateEmail,
            enabled: !authProvider.isLoading,
            onSubmitted: (_) => _handleReset(),
          ),
          const SizedBox(height: 28),

          // Anti-spam guarded submit button (disabled during request)
          PrimaryButton(
            label: 'Send Reset Link',
            isLoading: authProvider.isLoading,
            onPressed: authProvider.isLoading ? null : _handleReset,
          ),
          const SizedBox(height: 20),

          // Return to sign in
          TextButton(
            onPressed: () {
              authProvider.clearError();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x3316A34A) : AppColors.successLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: (isDark ? const Color(0xFF4ADE80) : AppColors.success).withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 32,
            color: isDark ? const Color(0xFF4ADE80) : AppColors.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We have sent a password reset link to:\n$_sentToEmail',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please follow the instructions in the email to set a new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMutedOf(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Back to Sign In',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
