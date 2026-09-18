import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = _passwordController.text.isEmpty
          ? 'Password is required'
          : null;
    });

    if (_emailError != null || _passwordError != null) return;

    FocusScope.of(context).unfocus();

    await authProvider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
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
                            AppColors.primaryDarker.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.85),
                          ]
                        : [
                            AppColors.primaryDarker,
                            Colors.white,
                          ],
                  ),
                ),
              ),
            ),

            // ── Scrollable content ──
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
                          top: 16,
                          bottom: bottomInset + 32,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                      // ── App Icon ──
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Title ──
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to access your personal notes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondaryOf(context),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Error Banner ──
                      if (authProvider.errorMessage != null) ...[
                        _ErrorBanner(
                          message: authProvider.errorMessage!,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Email Field ──
                      AppTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        label: 'Email',
                        showLabel: false,
                        hint: 'Email',
                        prefixIcon: Icons.mail_outlined,
                        textInputAction: TextInputAction.next,
                        errorText: _emailError,
                        onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        onChanged: (_) {
                          if (authProvider.errorMessage != null) {
                            authProvider.clearError();
                          }
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password Field ──
                      AppTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        label: 'Password',
                        showLabel: false,
                        hint: 'Password',
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        errorText: _passwordError,
                        onSubmitted: (_) => _handleLogin(),
                        onChanged: (_) {
                          if (authProvider.errorMessage != null) {
                            authProvider.clearError();
                          }
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),

                      // ── Forgot Password ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            authProvider.clearError();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Sign In Button ──
                      PrimaryButton(
                        label: 'Sign in',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleLogin,
                        backgroundColor: primaryColor,
                      ),
                      const SizedBox(height: 24),

                      // ── Don't have account? Signup ──
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't Have Account? ",
                              style: TextStyle(
                                color: AppColors.textSecondaryOf(context),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                authProvider.clearError();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Signup',
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
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared error banner used by auth screens.
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
