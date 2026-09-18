import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/data/services/auth_service.dart';
import 'package:personal_notes_app/providers/auth_provider.dart';
import 'package:personal_notes_app/ui/screens/auth/forgot_password_screen.dart';
import 'package:personal_notes_app/ui/screens/auth/login_screen.dart';
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
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('SignUpScreen renders email, password, confirm password fields', (tester) async {
      await tester.pumpWidget(createAuthTestWidget(const SignUpScreen()));

      expect(find.text('Create Account'), findsNWidgets(2)); // Title and Button
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders instructions and submit button', (tester) async {
      await tester.pumpWidget(createAuthTestWidget(const ForgotPasswordScreen()));

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });
  });
}
