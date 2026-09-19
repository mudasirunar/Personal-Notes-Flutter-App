import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/constants/app_constants.dart';
import 'package:personal_notes_app/data/models/note_model.dart';
import 'package:personal_notes_app/data/services/notes_service.dart';
import 'package:personal_notes_app/providers/notes_provider.dart';

class _MockNotesService extends Fake implements NotesService {
  final StreamController<List<NoteModel>> _controller =
      StreamController<List<NoteModel>>.broadcast();

  @override
  Stream<List<NoteModel>> getNotesStream(String userId) => _controller.stream;

  void emit(List<NoteModel> notes) {
    _controller.add(notes);
  }
}

void main() {
  group('Search Relevance and Ranking Tests', () {
    late _MockNotesService notesService;
    late NotesProvider provider;

    setUp(() async {
      notesService = _MockNotesService();
      provider = NotesProvider(notesService: notesService);
      provider.updateUser('test-user');
    });

    test('prioritizes title match over description match for "stud"', () async {
      final notes = [
        NoteModel(
          id: '1',
          title: 'Daily Journal',
          content: 'Today I need to study for physics and chemistry exam.',
          category: NoteCategory.personal,
          createdAt: DateTime(2026, 9, 1, 10, 0),
          updatedAt: DateTime(2026, 9, 1, 10, 0),
        ),
        NoteModel(
          id: '2',
          title: 'Study Plan',
          content: 'Overview of courses to complete this semester.',
          category: NoteCategory.study,
          createdAt: DateTime(2026, 8, 1, 10, 0),
          updatedAt: DateTime(2026, 8, 1, 10, 0),
        ),
      ];

      notesService.emit(notes);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      provider.setSearchQuery('stud');
      final results = provider.filteredNotes;

      expect(results.length, equals(2));
      // Note with "Study Plan" in title must be first
      expect(results[0].title, equals('Study Plan'));
      // Note with "study" only in description must be second
      expect(results[1].title, equals('Daily Journal'));
    });

    test('prioritizes prefix and word-start over middle-of-word matches and sorts alphabetically', () async {
      final notes = [
        NoteModel(
          id: '1',
          title: 'Table Repair',
          content: 'Fix the wooden table in the garage.',
          category: NoteCategory.personal,
        ),
        NoteModel(
          id: '2',
          title: 'Book Recommendations',
          content: 'Read classic literature this fall.',
          category: NoteCategory.study,
        ),
        NoteModel(
          id: '3',
          title: 'Banana Bread Recipe',
          content: '3 ripe bananas, flour, sugar, baking powder.',
          category: NoteCategory.personal,
        ),
        NoteModel(
          id: '4',
          title: 'Grocery Checklist',
          content: 'Remember to buy fresh berries and butter.',
          category: NoteCategory.work,
        ),
      ];

      notesService.emit(notes);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      provider.setSearchQuery('b');
      final results = provider.filteredNotes;

      // When searching "b":
      // 1. "Banana Bread Recipe" (starts with 'b') & "Book Recommendations" (starts with 'b')
      //    Alphabetical tie-break: "Banana Bread Recipe" then "Book Recommendations"
      // 2. "Table Repair" ('b' is in the middle of word "Table" at index 2)
      // 3. "Grocery Checklist" (title has no 'b', description has 'berries' and 'butter')
      expect(results.length, equals(4));
      expect(results[0].title, equals('Banana Bread Recipe'));
      expect(results[1].title, equals('Book Recommendations'));
      expect(results[2].title, equals('Table Repair'));
      expect(results[3].title, equals('Grocery Checklist'));
    });

    test('exact title match is prioritized above all others', () async {
      final notes = [
        NoteModel(
          id: '1',
          title: 'Study Guide and Schedule',
          content: 'Detailed notes',
          category: NoteCategory.study,
        ),
        NoteModel(
          id: '2',
          title: 'Study',
          content: 'Quick note',
          category: NoteCategory.study,
        ),
        NoteModel(
          id: '3',
          title: 'Self-Study Methods',
          content: 'Techniques for learning',
          category: NoteCategory.study,
        ),
      ];

      notesService.emit(notes);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      provider.setSearchQuery('study');
      final results = provider.filteredNotes;

      expect(results.length, equals(3));
      // Exact title match "Study" should be #1
      expect(results[0].title, equals('Study'));
      // Starts-with "Study Guide and Schedule" should be #2
      expect(results[1].title, equals('Study Guide and Schedule'));
      // Contains word "Self-Study Methods" should be #3
      expect(results[2].title, equals('Self-Study Methods'));
    });

    test('empty query retains default ordering', () async {
      final notes = [
        NoteModel(
          id: '1',
          title: 'Zebra',
          content: 'Content',
          category: NoteCategory.personal,
          updatedAt: DateTime(2026, 9, 10),
        ),
        NoteModel(
          id: '2',
          title: 'Apple',
          content: 'Content',
          category: NoteCategory.personal,
          updatedAt: DateTime(2026, 9, 1),
        ),
      ];

      notesService.emit(notes);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      provider.setSearchQuery('');
      final results = provider.filteredNotes;

      expect(results[0].title, equals('Zebra'));
      expect(results[1].title, equals('Apple'));
    });

    test('favoriting a note retains chronological order without jumping to top', () async {
      final note1 = NoteModel(
        id: '1',
        title: 'Older Note',
        content: 'Content',
        category: NoteCategory.personal,
        isFavorite: false,
        updatedAt: DateTime(2026, 9, 1),
      );
      final note2 = NoteModel(
        id: '2',
        title: 'Newer Note',
        content: 'Content',
        category: NoteCategory.personal,
        isFavorite: false,
        updatedAt: DateTime(2026, 9, 10),
      );

      // List ordered by newest updated first: note2 then note1
      notesService.emit([note2, note1]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.filteredNotes.first.id, equals('2'));
      expect(provider.filteredNotes.last.id, equals('1'));

      // Toggle favorite on older note without updating updatedAt
      final updatedNote1 = note1.copyWith(isFavorite: true);
      notesService.emit([note2, updatedNote1]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Order must be preserved: note2 remains first, note1 remains last
      expect(provider.filteredNotes.first.id, equals('2'));
      expect(provider.filteredNotes.last.id, equals('1'));
      expect(provider.filteredNotes.last.isFavorite, isTrue);
    });
  });
}
