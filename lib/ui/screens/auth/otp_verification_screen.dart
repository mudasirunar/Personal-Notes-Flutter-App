import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/otp_service.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/primary_button.dart';
import 'set_new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String initialOtp;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.initialOtp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late String _currentOtp;
  late DateTime _otpTimestamp;

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes = List.generate(6, (index) {
    return FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  });

  int _resendCountdown = 45;
  Timer? _timer;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.initialOtp;
    _otpTimestamp = DateTime.now();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _resendCountdown = 45;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _enteredCode => _controllers.map((c) => c.text.trim()).join();

  bool get _isComplete => _enteredCode.length == 6;

  Future<void> _handleResend() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final newOtp = OtpService.generateOtp();
    final error = await OtpService.sendOtpEmail(
      recipientEmail: widget.email,
      otpCode: newOtp,
    );

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (error != null) {
      AppToast.show(context, message: error, type: AppToastType.error);
    } else {
      _currentOtp = newOtp;
      _otpTimestamp = DateTime.now();
      _startCountdown();

      // Clear all fields
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();

      AppToast.show(
        context,
        message: 'A new 6-digit code has been sent to your email.',
        type: AppToastType.info,
      );
    }
  }

  void _handleVerify() {
    final code = _enteredCode;
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits.';
      });
      return;
    }

    // Check expiration (10 minutes)
    final elapsed = DateTime.now().difference(_otpTimestamp);
    if (elapsed.inMinutes >= 10) {
      setState(() {
        _errorMessage = 'This verification code has expired. Please tap Resend.';
      });
      return;
    }

    if (code != _currentOtp) {
      setState(() {
        _errorMessage = 'Invalid verification code. Please check and try again.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Navigate to Set New Password screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SetNewPasswordScreen(email: widget.email),
      ),
    );
  }

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    // Handle full paste (e.g. user pasted 6 digits into first box)
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].unfocus();
        _handleVerify();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-verify if all 6 digits entered
        if (_isComplete) {
          _handleVerify();
        }
      }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Shield Icon Header
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: primaryColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              Text(
                'Verification Code',
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
                'We have sent a 6-digit code to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),

              // 6 Digit OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 54,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryOf(context),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppColors.cardSurfaceOf(context),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.borderOf(context),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) => _onDigitChanged(index, val),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Error Message Banner
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.errorOf(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Verify Button
              PrimaryButton(
                label: 'Verify Code',
                onPressed: _handleVerify,
                backgroundColor: primaryColor,
              ),
              const SizedBox(height: 24),

              // Resend Code Section
              Center(
                child: _resendCountdown > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppColors.textSecondaryOf(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in ${_resendCountdown}s',
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : TextButton(
                        onPressed: _isResending ? null : _handleResend,
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Resend Code',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
