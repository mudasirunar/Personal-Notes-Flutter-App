import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/constants/app_constants.dart';
import 'package:personal_notes_app/data/models/note_model.dart';
import 'package:personal_notes_app/data/services/auth_service.dart';
import 'package:personal_notes_app/data/services/notes_service.dart';
import 'package:personal_notes_app/providers/auth_provider.dart';
import 'package:personal_notes_app/providers/notes_provider.dart';
import 'package:personal_notes_app/ui/screens/notes/add_edit_note_screen.dart';
import 'package:personal_notes_app/ui/screens/notes/notes_home_screen.dart';
import 'package:personal_notes_app/ui/widgets/category_badge.dart';
import 'package:personal_notes_app/ui/widgets/note_card.dart';
import 'package:provider/provider.dart';

class _FakeNotesService extends Fake implements NotesService {
  final _streamController = StreamController<List<NoteModel>>.broadcast();
  List<NoteModel> notes = [];

  @override
  Stream<List<NoteModel>> getNotesStream(String userId) {
    return _streamController.stream;
  }

  void emit(List<NoteModel> newNotes) {
    notes = newNotes;
    _streamController.add(notes);
  }

  @override
  Future<String> createNote({required String userId, required NoteModel note}) async {
    notes.add(note.copyWith(id: 'generated-id'));
    _streamController.add(notes);
    return 'generated-id';
  }

  @override
  Future<void> updateNote({required String userId, required NoteModel note}) async {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      _streamController.add(notes);
    }
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String noteId,
    required bool currentStatus,
  }) async {
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      notes[index] = notes[index].copyWith(isFavorite: !currentStatus);
      _streamController.add(notes);
    }
  }

  @override
  Future<void> deleteNote({required String userId, required String noteId}) async {
    notes.removeWhere((n) => n.id == noteId);
    _streamController.add(notes);
  }
}

class _FakeAuthService extends Fake implements AuthService {
  final _controller = StreamController<User?>.broadcast();

  _FakeAuthService() {
    scheduleMicrotask(() {
      if (!_controller.isClosed) {
        _controller.add(null);
      }
    });
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => null;

  @override
  String? get currentUserId => 'test-user-123';

  @override
  String? get currentUserEmail => 'test@example.com';
}

void main() {
  late _FakeNotesService fakeNotesService;
  late NotesProvider notesProvider;
  late AuthProvider authProvider;

  setUp(() {
    fakeNotesService = _FakeNotesService();
    notesProvider = NotesProvider(notesService: fakeNotesService);
    authProvider = AuthProvider(authService: _FakeAuthService());
    notesProvider.updateUser('test-user-123');
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<NotesProvider>.value(value: notesProvider),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('NotesHomeScreen Tests', () {
    testWidgets('renders empty state when no notes exist', (tester) async {
      fakeNotesService.emit([]);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      expect(find.text('My Notes'), findsOneWidget);
      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Create a Note'), findsOneWidget);
      // When empty state CTA is present, FAB is hidden to eliminate redundant CTAs
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('renders note cards and FAB when notes are emitted', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Sprint Planning',
          content: 'Discuss sprint 4 deliverables',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
        NoteModel(
          id: 'note-2',
          title: 'Study Flutter',
          content: 'Practice widget testing',
          category: NoteCategory.study,
          isFavorite: true,
          createdAt: DateTime(2026, 9, 18, 9, 0),
          updatedAt: DateTime(2026, 9, 18, 9, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      expect(find.text('Sprint Planning'), findsOneWidget);
      expect(find.text('Study Flutter'), findsOneWidget);
      expect(find.text('Work'), findsWidgets);
      expect(find.text('Study'), findsWidgets);
      // FAB is visible when notes exist
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('filters notes by search query', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Sprint Planning',
          content: 'Discuss sprint 4 deliverables',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
        NoteModel(
          id: 'note-2',
          title: 'Grocery List',
          content: 'Milk, bread, eggs',
          category: NoteCategory.personal,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 9, 0),
          updatedAt: DateTime(2026, 9, 18, 9, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'sprint');
      await tester.pump();

      expect(find.text('Sprint Planning'), findsOneWidget);
      expect(find.text('Grocery List'), findsNothing);

      // Search by description/content
      await tester.enterText(find.byType(TextField), 'eggs');
      await tester.pump();

      expect(find.text('Grocery List'), findsOneWidget);
      expect(find.text('Sprint Planning'), findsNothing);
    });

    testWidgets('search ranks title matches ahead of description matches and orders alphabetically', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Daily Journal',
          content: 'Today I need to study physics and chemistry.',
          category: NoteCategory.personal,
          createdAt: DateTime(2026, 9, 18, 10, 0),
        ),
        NoteModel(
          id: 'note-2',
          title: 'Study Plan',
          content: 'Tasks to finish this semester.',
          category: NoteCategory.study,
          createdAt: DateTime(2026, 9, 18, 9, 0),
        ),
        NoteModel(
          id: 'note-3',
          title: 'Study Notes for Calculus',
          content: 'Derivatives and integrals.',
          category: NoteCategory.study,
          createdAt: DateTime(2026, 9, 18, 8, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'stud');
      await tester.pump();

      // Verify NoteCards are displayed in prioritized relevance & alphabetical order:
      // 1. "Study Notes for Calculus" & "Study Plan" (both title prefix match, sorted alphabetically)
      // 2. "Daily Journal" (only content matches "study")
      final cards = tester.widgetList<NoteCard>(find.byType(NoteCard)).toList();
      expect(cards.length, equals(3));
      expect(cards[0].note.title, equals('Study Notes for Calculus'));
      expect(cards[1].note.title, equals('Study Plan'));
      expect(cards[2].note.title, equals('Daily Journal'));
    });

    testWidgets('renders all 5 filter chips and filters notes mutually exclusively', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Work Note 1',
          content: 'Work content',
          category: NoteCategory.work,
          isFavorite: true,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
        NoteModel(
          id: 'note-2',
          title: 'Personal Note 1',
          content: 'Personal content',
          category: NoteCategory.personal,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 9, 0),
          updatedAt: DateTime(2026, 9, 18, 9, 0),
        ),
        NoteModel(
          id: 'note-3',
          title: 'Study Note 1',
          content: 'Study content',
          category: NoteCategory.study,
          isFavorite: true,
          createdAt: DateTime(2026, 9, 18, 8, 0),
          updatedAt: DateTime(2026, 9, 18, 8, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Verify all 5 chips exist
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Personal'), findsWidgets);
      expect(find.text('Work'), findsWidgets);
      expect(find.text('Study'), findsWidgets);

      // Initially All (all 3 notes visible)
      expect(find.text('Work Note 1'), findsOneWidget);
      expect(find.text('Personal Note 1'), findsOneWidget);
      expect(find.text('Study Note 1'), findsOneWidget);

      // Tap Favorites -> only note-1 and note-3
      await tester.tap(find.byKey(const ValueKey('filter_chip_favorites')));
      await tester.pump();

      expect(find.text('Work Note 1'), findsOneWidget);
      expect(find.text('Study Note 1'), findsOneWidget);
      expect(find.text('Personal Note 1'), findsNothing);

      // Tap Personal chip -> only note-2
      await tester.tap(find.byKey(const ValueKey('filter_chip_personal')));
      await tester.pump();

      expect(find.text('Personal Note 1'), findsOneWidget);
      expect(find.text('Work Note 1'), findsNothing);
      expect(find.text('Study Note 1'), findsNothing);

      // Tap Work chip -> only note-1
      await tester.tap(find.byKey(const ValueKey('filter_chip_work')));
      await tester.pump();

      expect(find.text('Work Note 1'), findsOneWidget);
      expect(find.text('Personal Note 1'), findsNothing);
      expect(find.text('Study Note 1'), findsNothing);

      // Tap All chip -> restores all 3
      await tester.tap(find.byKey(const ValueKey('filter_chip_all')));
      await tester.pump();

      expect(find.text('Work Note 1'), findsOneWidget);
      expect(find.text('Personal Note 1'), findsOneWidget);
      expect(find.text('Study Note 1'), findsOneWidget);
    });

    testWidgets('renders contextual empty state for search with clear CTA', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Grocery Items',
          content: 'Milk, bread',
          category: NoteCategory.personal,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Search non-existent query
      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pump();

      expect(find.text('No matching notes'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);

      // Tap Clear Search
      await tester.tap(find.text('Clear Search'));
      await tester.pump();

      expect(find.text('Grocery Items'), findsOneWidget);
    });

    testWidgets('renders contextual empty state for favorites and category filters', (tester) async {
      // Only personal non-favorite note
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Personal Note',
          content: 'Secret thoughts',
          category: NoteCategory.personal,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Tap Favorites -> zero favorites
      await tester.tap(find.byKey(const ValueKey('filter_chip_favorites')));
      await tester.pump();

      expect(find.text('No favorite notes yet'), findsOneWidget);
      expect(find.text('Explore All Notes'), findsOneWidget);

      // Tap Explore All Notes -> restores all notes
      await tester.tap(find.text('Explore All Notes'));
      await tester.pump();

      expect(find.text('Personal Note'), findsOneWidget);

      // Tap Work -> zero work notes
      await tester.tap(find.byKey(const ValueKey('filter_chip_work')));
      await tester.pump();

      expect(find.text('No work notes yet'), findsOneWidget);
      expect(find.text('Add Work Note'), findsOneWidget);

      // Tap Study -> zero study notes
      await tester.tap(find.byKey(const ValueKey('filter_chip_study')));
      await tester.pump();

      expect(find.text('No study notes yet'), findsOneWidget);
      expect(find.text('Add Study Note'), findsOneWidget);
    });

    testWidgets('tapping FAB under active category filter preselects that category in AddEditNoteScreen', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Work Project',
          content: 'Important work stuff',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Tap Work filter chip
      await tester.tap(find.byKey(const ValueKey('filter_chip_work')));
      await tester.pump();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // rotation controller
      await tester.pump(const Duration(milliseconds: 350)); // navigator push transition

      // AddEditNoteScreen should open with Work category pre-selected
      expect(find.text('New Note'), findsOneWidget);
      final workBadge = tester.widget<CategoryBadge>(
        find.descendant(
          of: find.byType(AddEditNoteScreen),
          matching: find.byWidgetPredicate(
            (w) => w is CategoryBadge && w.category == NoteCategory.work,
          ),
        ),
      );
      expect(workBadge.isSelected, isTrue);
    });

    testWidgets('FAB slides down when scrolling down on long list and slides back up when scrolling up', (tester) async {
      final sampleNotes = List.generate(
        15,
        (i) => NoteModel(
          id: 'note-$i',
          title: 'Note Title $i',
          content: 'Some long note content paragraph for note $i to ensure tall list view',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, i),
          updatedAt: DateTime(2026, 9, 18, 10, i),
        ),
      );

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final initialAnimatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(of: fabFinder, matching: find.byType(AnimatedSlide)),
      );
      expect(initialAnimatedSlide.offset, Offset.zero);

      // Drag/scroll down on the list
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      final hiddenAnimatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(of: fabFinder, matching: find.byType(AnimatedSlide)),
      );
      expect(hiddenAnimatedSlide.offset, const Offset(0, 2));

      // Drag/scroll back up on the list
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();

      final revealedAnimatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(of: fabFinder, matching: find.byType(AnimatedSlide)),
      );
      expect(revealedAnimatedSlide.offset, Offset.zero);
    });

    testWidgets('FAB does NOT hide when screen is not scrollable (few notes)', (tester) async {
      final sampleNotes = [
        NoteModel(
          id: 'note-1',
          title: 'Single Note',
          content: 'Short content',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Try dragging
      await tester.drag(find.byType(ListView), const Offset(0, -50));
      await tester.pump();

      final animatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(of: fabFinder, matching: find.byType(AnimatedSlide)),
      );
      // Offset should still be zero (not hidden) because list is not scrollable
      expect(animatedSlide.offset, Offset.zero);
    });

    testWidgets('empty screen CTA button does NOT stretch in landscape mode', (tester) async {
      fakeNotesService.emit([]);

      // Set landscape viewport: 1000px wide
      tester.view.physicalSize = const Size(1000, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final buttonSize = tester.getSize(buttonFinder);
      // Button width must be capped and not stretch across the 1000px viewport
      expect(buttonSize.width, lessThanOrEqualTo(240));
      expect(buttonSize.width, greaterThanOrEqualTo(140));
    });

    testWidgets('translucent top section renders frosted blur and absorbs taps so notes behind are not clickable', (tester) async {
      final sampleNotes = List.generate(
        8,
        (i) => NoteModel(
          id: 'note-$i',
          title: 'Note Title $i',
          content: 'Content for note $i',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, i),
          updatedAt: DateTime(2026, 9, 18, 10, i),
        ),
      );

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Verify BackdropFilter with blur is rendered in top bar
      expect(find.byType(BackdropFilter), findsWidgets);

      // Drag list upwards by 200px so notes scroll underneath the top header
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // Tap on empty space within the top header area (e.g. Offset(350, 40))
      // Notes are physically underneath this coordinate, but header must intercept the tap
      await tester.tapAt(const Offset(350, 40));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Must NOT navigate to AddEditNoteScreen; stays on home screen
      expect(find.byType(AddEditNoteScreen), findsNothing);
      expect(find.byType(NotesHomeScreen), findsOneWidget);
    });

    testWidgets('tapping search bar does not scroll to top, but typing resets scroll to top', (tester) async {
      final sampleNotes = List.generate(
        12,
        (i) => NoteModel(
          id: 'note-$i',
          title: i < 3 ? 'Alpha Result $i' : 'Other Note $i',
          content: 'Content for note $i',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, i),
          updatedAt: DateTime(2026, 9, 18, 10, i),
        ),
      );

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pump();

      // Scroll down by 400px so user is far down in the list
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();

      // Tap on search bar - must NOT scroll to top
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Top notes (Alpha Result 0) must still be scrolled off-screen
      expect(find.text('Alpha Result 0'), findsNothing);

      // Enter search query (user starts typing) - MUST reset scroll to top smoothly
      await tester.enterText(find.byType(TextField), 'Alpha');
      await tester.pumpAndSettle();

      // First result must be visible in the viewport and start below the header
      expect(find.text('Alpha Result 0'), findsOneWidget);
      final firstCardTop = tester.getTopLeft(find.text('Alpha Result 0')).dy;
      // Top of first card text must be below the top header (~168px)
      expect(firstCardTop, greaterThan(168.0));
    });

    testWidgets('switching category when list is scrolled up smoothly animates cards down into view', (tester) async {
      final sampleNotes = List.generate(
        10,
        (i) => NoteModel(
          id: 'note-$i',
          title: i < 5 ? 'Work Note $i' : 'Personal Note $i',
          content: 'Content for note $i',
          category: i < 5 ? NoteCategory.work : NoteCategory.personal,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 10, i),
          updatedAt: DateTime(2026, 9, 18, 10, i),
        ),
      );

      fakeNotesService.emit(sampleNotes);

      await tester.pumpWidget(createTestWidget(const NotesHomeScreen()));
      await tester.pumpAndSettle();

      // Scroll down so top notes are behind/above the top bar
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Tap Work filter chip
      await tester.tap(find.byKey(const ValueKey('filter_chip_work')));
      await tester.pumpAndSettle();

      // Top work note must be cleanly visible below header
      expect(find.text('Work Note 0'), findsOneWidget);
      final firstWorkCardTop = tester.getTopLeft(find.text('Work Note 0')).dy;
      expect(firstWorkCardTop, greaterThan(168.0));
    });
  });

  group('AddEditNoteScreen Tests', () {
    testWidgets('renders create mode fields with default values', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddEditNoteScreen()));

      expect(find.text('New Note'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Note Content'), findsOneWidget);
      expect(find.text('Create Note'), findsOneWidget);
    });

    testWidgets('validates empty title on submission', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddEditNoteScreen()));

      await tester.tap(find.text('Create Note'));
      await tester.pump();

      expect(find.text('Title cannot be empty or whitespace only'), findsOneWidget);
    });

    testWidgets('renders edit mode with existing note data', (tester) async {
      final noteToEdit = NoteModel(
        id: 'edit-1',
        title: 'Existing Note',
        content: 'Existing content here',
        category: NoteCategory.study,
        isFavorite: true,
        createdAt: DateTime(2026, 9, 18, 10, 0),
        updatedAt: DateTime(2026, 9, 18, 10, 0),
      );

      await tester.pumpWidget(createTestWidget(AddEditNoteScreen(note: noteToEdit)));

      expect(find.text('Edit Note'), findsOneWidget);
      expect(find.text('Existing Note'), findsOneWidget);
      expect(find.text('Existing content here'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('pre-selects initialCategory when provided in create mode', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddEditNoteScreen(
        initialCategory: NoteCategory.work,
      )));

      final workBadge = tester.widget<CategoryBadge>(
        find.byWidgetPredicate((w) => w is CategoryBadge && w.category == NoteCategory.work),
      );
      expect(workBadge.isSelected, isTrue);
    });
  });
}
