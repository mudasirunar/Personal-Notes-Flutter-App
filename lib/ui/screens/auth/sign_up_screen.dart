import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    setState(() {
      _fullNameError = Validators.validateFullName(_fullNameController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError = Validators.validateConfirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });

    if (_fullNameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await authProvider.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final primaryColor = AppColors.primary;
    final circleSize = size.longestSide * 0.46;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // ── Background gradient ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF0B0D1A), const Color(0xFF111336)]
                      : [const Color(0xFFF8FAFC), const Color(0xFFEEF0FB)],
                ),
              ),
            ),

            // ── Decorative gradient circle (top-right) ──
            Positioned(
              top: -circleSize * 0.17,
              right: -circleSize * 0.48,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.primaryDark.withValues(alpha: 0.92),
                            Colors.white.withValues(alpha: 0.85),
                          ]
                        : [
                            AppColors.primaryDark,
                            Colors.white,
                          ],
                  ),
                ),
              ),
            ),

            // ── Scrollable form (full height under transparent top bar) ──
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                          left: 28,
                          right: 28,
                          top: 56,
                          bottom: bottomInset + 32,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                      // ── Title & Subtext (Centered) ──
                                      Text(
                                        'Create Account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Signup to get started',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.textSecondaryOf(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                            // ── Error Banner ──
                            if (authProvider.errorMessage != null) ...[
                              _ErrorBanner(
                                message: authProvider.errorMessage!,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 20),
                            ],

                            // ── Full Name ──
                            AppTextField(
                              controller: _fullNameController,
                              focusNode: _fullNameFocusNode,
                              label: 'Full Name',
                              showLabel: false,
                              hint: 'Full Name',
                              prefixIcon: Icons.person_outline_rounded,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              errorText: _fullNameError,
                              onSubmitted: (_) =>
                                  _emailFocusNode.requestFocus(),
                              onChanged: (_) {
                                if (authProvider.errorMessage != null) {
                                  authProvider.clearError();
                                }
                                if (_fullNameError != null) {
                                  setState(() => _fullNameError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Email ──
                            AppTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email',
                              showLabel: false,
                              hint: 'Email',
                              prefixIcon: Icons.mail_outlined,
                              textInputAction: TextInputAction.next,
                              errorText: _emailError,
                              onSubmitted: (_) =>
                                  _passwordFocusNode.requestFocus(),
                              onChanged: (_) {
                                if (authProvider.errorMessage != null) {
                                  authProvider.clearError();
                                }
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Password ──
                            AppTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: 'Password',
                              showLabel: false,
                              hint: 'Password',
                              isPassword: true,
                              textInputAction: TextInputAction.next,
                              errorText: _passwordError,
                              onSubmitted: (_) =>
                                  _confirmPasswordFocusNode.requestFocus(),
                              onChanged: (_) {
                                if (authProvider.errorMessage != null) {
                                  authProvider.clearError();
                                }
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Confirm Password ──
                            AppTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              label: 'Confirm Password',
                              showLabel: false,
                              hint: 'Confirm Password',
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              errorText: _confirmPasswordError,
                              onSubmitted: (_) => _handleSignUp(),
                              onChanged: (_) {
                                if (authProvider.errorMessage != null) {
                                  authProvider.clearError();
                                }
                                if (_confirmPasswordError != null) {
                                  setState(() => _confirmPasswordError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 32),

                            // ── Sign Up Button ──
                            PrimaryButton(
                              label: 'Sign up',
                              isLoading: authProvider.isLoading,
                              onPressed: _handleSignUp,
                              backgroundColor: primaryColor,
                            ),
                            const SizedBox(height: 24),

                            // ── Back to Login ──
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: AppColors.textSecondaryOf(context),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      authProvider.clearError();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Floating Pinned Back button (content scrolls behind) ──
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: () {
                    authProvider.clearError();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared error banner.
// ═══════════════════════════════════════════════════════════════════════════════
class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;

  const _ErrorBanner({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final errorColor = isDark ? AppColors.errorDark : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.errorLightDark : AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: errorColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: errorColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
