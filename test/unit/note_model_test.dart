import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/constants/app_constants.dart';
import 'package:personal_notes_app/data/models/note_model.dart';

void main() {
  group('NoteModel Tests', () {
    final testDate = DateTime(2026, 9, 18, 10, 0);

    final model = NoteModel(
      id: 'note-123',
      title: ' Test Title ',
      content: ' Test Content ',
      category: NoteCategory.work,
      isFavorite: true,
      createdAt: testDate,
      updatedAt: testDate,
    );

    test('instantiates with correct fields', () {
      expect(model.id, 'note-123');
      expect(model.title, ' Test Title ');
      expect(model.content, ' Test Content ');
      expect(model.category, NoteCategory.work);
      expect(model.isFavorite, isTrue);
      expect(model.createdAt, testDate);
      expect(model.updatedAt, testDate);
    });

    test('toFirestoreForCreate trims values and includes createdAt', () {
      final map = model.toFirestoreForCreate();
      expect(map['title'], 'Test Title');
      expect(map['content'], 'Test Content');
      expect(map['category'], 'work');
      expect(map['isFavorite'], isTrue);
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('updatedAt'), isTrue);
    });

    test('toFirestoreForUpdate preserves createdAt (does not include in update map)', () {
      final map = model.toFirestoreForUpdate();
      expect(map['title'], 'Test Title');
      expect(map['content'], 'Test Content');
      expect(map['category'], 'work');
      expect(map['isFavorite'], isTrue);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('updatedAt'), isTrue);
    });

    test('copyWith updates specified fields only', () {
      final updated = model.copyWith(
        title: 'New Title',
        category: NoteCategory.study,
        isFavorite: false,
      );

      expect(updated.id, 'note-123');
      expect(updated.title, 'New Title');
      expect(updated.content, ' Test Content ');
      expect(updated.category, NoteCategory.study);
      expect(updated.isFavorite, isFalse);
    });

    test('NoteCategory conversion helpers work properly', () {
      expect(NoteCategory.fromString('work'), NoteCategory.work);
      expect(NoteCategory.fromString('study'), NoteCategory.study);
      expect(NoteCategory.fromString('personal'), NoteCategory.personal);
      expect(NoteCategory.fromString(null), NoteCategory.personal);
      expect(NoteCategory.fromString('unknown'), NoteCategory.personal);
    });
  });
}
