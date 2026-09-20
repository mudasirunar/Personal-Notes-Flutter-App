import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/constants/app_constants.dart';
import 'package:personal_notes_app/core/theme/app_theme.dart';
import 'package:personal_notes_app/data/models/note_model.dart';
import 'package:personal_notes_app/ui/widgets/category_badge.dart';
import 'package:personal_notes_app/ui/widgets/delete_note_dialog.dart';
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

    testWidgets('renders horizontal divider when showDivider is true, hides when false', (tester) async {
      final testNote = NoteModel(
        id: 'note-divider-test',
        title: 'Flat Note',
        content: 'Testing divider visibility',
        category: NoteCategory.work,
        isFavorite: false,
        createdAt: DateTime(2026, 9, 18, 10, 0),
        updatedAt: DateTime(2026, 9, 18, 10, 0),
      );

      // 1. showDivider: true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              showDivider: true,
              onTap: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Divider), findsOneWidget);

      // 2. showDivider: false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              showDivider: false,
              onTap: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Divider), findsNothing);
    });
  });

  group('DeleteNoteDialog Widget Tests', () {
    testWidgets('renders title and confirmation message with note name', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteNoteDialog.show(
                    context,
                    noteTitle: 'Grocery List',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Note'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete "Grocery List"? This action cannot be undone.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Delete Note'), findsNothing);
    });

    testWidgets('returns false when cancelled or dismissed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteNoteDialog.show(
                    context,
                    noteTitle: '',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Empty title fallback
      expect(
        find.text('Are you sure you want to delete "this note"? This action cannot be undone.'),
        findsOneWidget,
      );

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('shows loader on delete button, disables cancel, and blocks pop while deleting', (tester) async {
      final completer = Completer<void>();
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteNoteDialog.show(
                    context,
                    noteTitle: 'Important Note',
                    onDelete: () => completer.future,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Before tapping delete: Cancel is enabled, no loader
      final cancelFinder = find.widgetWithText(TextButton, 'Cancel');
      expect(tester.widget<TextButton>(cancelFinder).onPressed, isNotNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap Delete to initiate deletion
      await tester.tap(find.text('Delete'));
      await tester.pump(); // Triggers setState and rebuilds with _isLoading = true

      // During deletion:
      // 1. Loader is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // 2. Cancel button is disabled
      expect(tester.widget<TextButton>(cancelFinder).onPressed, isNull);
      // 3. PopScope prevents dismissing
      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      // Now complete the remote deletion
      completer.complete();
      await tester.pumpAndSettle();

      // Dialog closed with success
      expect(result, isTrue);
      expect(find.text('Delete Note'), findsNothing);
    });

    testWidgets('returns false when onDelete returns error', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteNoteDialog.show(
                    context,
                    noteTitle: 'Note With Error',
                    onDelete: () async => 'Network failed',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Deletion failed, so result is false
      expect(result, isFalse);
      expect(find.text('Delete Note'), findsNothing);
    });
  });
}

