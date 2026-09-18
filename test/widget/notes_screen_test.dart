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
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders note cards when notes are emitted', (tester) async {
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
          content: 'Read documentation on state management',
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
  });
}
