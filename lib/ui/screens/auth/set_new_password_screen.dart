import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/otp_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/primary_button.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final pErr = Validators.validatePassword(password);
    final cErr = Validators.validateConfirmPassword(password, confirmPassword);

    setState(() {
      _passwordError = pErr;
      _confirmPasswordError = cErr;
    });

    if (pErr != null || cErr != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await OtpService.updatePasswordViaBackend(
      email: widget.email,
      newPassword: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      AppToast.show(context, message: error, type: AppToastType.error);
    } else {
      // Pop all the way back to Login Screen
      Navigator.of(context).popUntil((route) => route.isFirst);

      // Show floating in-app success toast on Login Screen
      AppToast.show(
        context,
        message: 'Password reset successfully! Please log in with your new password.',
        type: AppToastType.success,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // Lock Icon Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: primaryColor,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Subtitle
                Text(
                  'Set New Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Must be at least 8 characters long',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondaryOf(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // New Password Field
                AppTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'New Password',
                  showLabel: true,
                  hint: 'Enter new password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _passwordError,
                  onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Confirm New Password Field
                AppTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  label: 'Confirm New Password',
                  showLabel: true,
                  hint: 'Re-enter new password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  errorText: _confirmPasswordError,
                  onSubmitted: (_) => _handleSubmit(),
                  onChanged: (_) {
                    if (_confirmPasswordError != null) {
                      setState(() => _confirmPasswordError = null);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                PrimaryButton(
                  label: 'Update Password',
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  backgroundColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
