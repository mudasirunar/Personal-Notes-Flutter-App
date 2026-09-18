import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/constants/app_constants.dart';
import 'package:personal_notes_app/core/theme/app_theme.dart';
import 'package:personal_notes_app/data/models/note_model.dart';
import 'package:personal_notes_app/ui/widgets/category_badge.dart';
import 'package:personal_notes_app/ui/widgets/empty_state_view.dart';
import 'package:personal_notes_app/ui/widgets/note_card.dart';
import 'package:personal_notes_app/ui/widgets/primary_button.dart';

void main() {
  group('CategoryBadge Widget Tests', () {
    testWidgets('renders category label correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryBadge(category: NoteCategory.work),
          ),
        ),
      );

      expect(find.text('Work'), findsOneWidget);
      expect(find.byIcon(Icons.work_outline_rounded), findsOneWidget);
    });
  });

  group('PrimaryButton Widget Tests', () {
    testWidgets('renders button and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Submit',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading indicator and disables tap when isLoading is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Submit',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
      await tester.tap(find.byType(PrimaryButton));
      expect(tapped, isFalse);
    });
  });

  group('EmptyStateView Widget Tests', () {
    testWidgets('renders empty state content and action button', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView.noNotes(
              onCreateNote: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Create a Note'), findsOneWidget);

      await tester.tap(find.text('Create a Note'));
      expect(actionTriggered, isTrue);
    });
  });

  group('NoteCard Widget Tests', () {
    testWidgets('renders note card title, snippet, and favorite star', (tester) async {
      bool cardTapped = false;
      bool favoriteToggled = false;

      final testNote = NoteModel(
        id: 'test-1',
        title: 'Project Architecture',
        content: 'Clean architecture with Provider and Firebase',
        category: NoteCategory.work,
        isFavorite: true,
        createdAt: DateTime(2026, 9, 18, 10, 0),
        updatedAt: DateTime(2026, 9, 18, 10, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => cardTapped = true,
              onToggleFavorite: () => favoriteToggled = true,
            ),
          ),
        ),
      );

      expect(find.text('Project Architecture'), findsOneWidget);
      expect(find.text('Clean architecture with Provider and Firebase'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);

      // Tap card
      await tester.tap(find.text('Project Architecture'));
      expect(cardTapped, isTrue);

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.star_rounded));
      expect(favoriteToggled, isTrue);
    });

    testWidgets('renders properly with darkTheme applied', (tester) async {
      final testNote = NoteModel(
        id: 'note-dark-1',
        title: 'Dark Mode Note',
        content: 'This note renders with dark theme colors',
        category: NoteCategory.personal,
        isFavorite: false,
        createdAt: DateTime(2026, 9, 18, 10, 0),
        updatedAt: DateTime(2026, 9, 18, 10, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dark Mode Note'), findsOneWidget);
      expect(find.text('This note renders with dark theme colors'), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });
  });
}
