import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/data/services/auth_service.dart';
import 'package:personal_notes_app/providers/auth_provider.dart';
import 'package:personal_notes_app/ui/screens/auth/forgot_password_screen.dart';
import 'package:personal_notes_app/ui/screens/auth/login_screen.dart';
import 'package:personal_notes_app/ui/screens/auth/otp_verification_screen.dart';
import 'package:personal_notes_app/ui/screens/auth/set_new_password_screen.dart';
import 'package:personal_notes_app/ui/screens/auth/sign_up_screen.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class FakeAuthService extends Fake implements AuthService {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => null;

  @override
  String? get currentUserId => null;

  @override
  String? get currentUserEmail => null;

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  Widget createAuthTestWidget(Widget child) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(authService: FakeAuthService() as dynamic),
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Auth Screens Widget Tests', () {
    testWidgets('LoginScreen renders all input fields and actions', (tester) async {
      await tester.pumpWidget(createAuthTestWidget(const LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forget Password?'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Signup'), findsOneWidget);
    });

    testWidgets('SignUpScreen renders full name, email, password, confirm password fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAuthTestWidget(const SignUpScreen()));

      expect(find.text('Create Account'), findsOneWidget); // Title
      expect(find.text('Sign up'), findsOneWidget); // Button
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders instructions and submit button', (tester) async {
      await tester.pumpWidget(createAuthTestWidget(const ForgotPasswordScreen()));

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen renders 6-digit fields and countdown timer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OtpVerificationScreen(
            email: 'test@example.com',
            initialOtp: '123456',
          ),
        ),
      );

      expect(find.text('Verification Code'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
      expect(find.text('Verify Code'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsOneWidget);
    });

    testWidgets('SetNewPasswordScreen renders new password and confirm password fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetNewPasswordScreen(email: 'test@example.com'),
        ),
      );

      expect(find.text('Set New Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
    });
  });
}
