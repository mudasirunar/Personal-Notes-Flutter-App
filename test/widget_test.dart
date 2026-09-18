import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/data/services/auth_service.dart';
import 'package:personal_notes_app/main.dart';

class _FakeAuthService extends Fake implements AuthService {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => null;

  @override
  String? get currentUserId => null;

  @override
  String? get currentUserEmail => null;
}

void main() {
  testWidgets('App smoke test initializes properly', (WidgetTester tester) async {
    await tester.pumpWidget(PersonalNotesApp(authService: _FakeAuthService()));
    expect(find.byType(PersonalNotesApp), findsOneWidget);
  });
}
