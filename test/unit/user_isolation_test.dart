import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/constants/app_constants.dart';
import 'package:personal_notes_app/data/models/note_model.dart';
import 'package:personal_notes_app/data/services/notes_service.dart';
import 'package:personal_notes_app/providers/notes_provider.dart';

class _IsolationNotesService extends Fake implements NotesService {
  final Map<String, StreamController<List<NoteModel>>> _userStreams = {};
  final Map<String, List<NoteModel>> _database = {};

  @override
  Stream<List<NoteModel>> getNotesStream(String userId) {
    _userStreams[userId] ??= StreamController<List<NoteModel>>.broadcast();
    Future.microtask(() {
      final userNotes = _database[userId] ?? [];
      _userStreams[userId]?.add(List.from(userNotes));
    });
    return _userStreams[userId]!.stream;
  }

  void seedNotes(String userId, List<NoteModel> notes) {
    _database[userId] = List.from(notes);
    _userStreams[userId]?.add(List.from(notes));
  }
}

void main() {
  group('User Data Isolation Tests', () {
    late _IsolationNotesService notesService;
    late NotesProvider notesProvider;

    setUp(() {
      notesService = _IsolationNotesService();
      notesProvider = NotesProvider(notesService: notesService);
    });

    test('User B cannot see User A data after switching account or logout', () async {
      // 1. User A logs in and has private notes
      final userANotes = [
        NoteModel(
          id: 'note-user-a-1',
          title: 'Secret Notes for User A',
          content: 'Confidential content',
          category: NoteCategory.personal,
          isFavorite: true,
          createdAt: DateTime(2026, 9, 18, 10, 0),
          updatedAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ];
      notesService.seedNotes('user-A', userANotes);

      notesProvider.updateUser('user-A');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(notesProvider.allNotes.length, equals(1));
      expect(notesProvider.allNotes.first.title, equals('Secret Notes for User A'));

      // 2. User A logs out (null user) -> instant synchronous data wipe
      notesProvider.updateUser(null);

      expect(notesProvider.allNotes, isEmpty);
      expect(notesProvider.filteredNotes, isEmpty);
      expect(notesProvider.searchQuery, isEmpty);
      expect(notesProvider.favoritesOnly, isFalse);
      expect(notesProvider.selectedCategory, isNull);

      // 3. User B logs in -> User B receives only User B notes
      final userBNotes = [
        NoteModel(
          id: 'note-user-b-1',
          title: 'User B Work Tasks',
          content: 'Tasks for project B',
          category: NoteCategory.work,
          isFavorite: false,
          createdAt: DateTime(2026, 9, 18, 11, 0),
          updatedAt: DateTime(2026, 9, 18, 11, 0),
        ),
      ];
      notesService.seedNotes('user-B', userBNotes);

      notesProvider.updateUser('user-B');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(notesProvider.allNotes.length, equals(1));
      expect(notesProvider.allNotes.first.title, equals('User B Work Tasks'));
      expect(
        notesProvider.allNotes.any((n) => n.title.contains('User A')),
        isFalse,
      );
    });
  });
}
