import 'package:flutter_test/flutter_test.dart';
import 'package:personal_notes_app/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('rejects empty, null and whitespace email', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('   '), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('rejects invalid email formats', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('user@domain'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
    });

    test('accepts valid email formats', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@sub.domain.org'), isNull);
    });
  });

  group('Validators - Password', () {
    test('rejects passwords shorter than 8 characters', () {
      expect(Validators.validatePassword('1234567'), isNotNull);
      expect(Validators.validatePassword('abc'), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('accepts passwords with 8 or more characters', () {
      expect(Validators.validatePassword('12345678'), isNull);
      expect(Validators.validatePassword('StrongPassword123!'), isNull);
    });

    test('validates confirm password matches password', () {
      expect(Validators.validateConfirmPassword('pass1234', 'pass1234'), isNull);
      expect(Validators.validateConfirmPassword('pass1234', 'diff1234'), isNotNull);
      expect(Validators.validateConfirmPassword('', 'pass1234'), isNotNull);
      expect(Validators.validateConfirmPassword(null, 'pass1234'), isNotNull);
    });
  });

  group('Validators - Note Title', () {
    test('rejects empty or whitespace-only titles', () {
      expect(Validators.validateNoteTitle(''), isNotNull);
      expect(Validators.validateNoteTitle('   '), isNotNull);
      expect(Validators.validateNoteTitle('\n\t  '), isNotNull);
      expect(Validators.validateNoteTitle(null), isNotNull);
    });

    test('rejects titles longer than 80 characters', () {
      final longTitle = 'A' * 81;
      expect(Validators.validateNoteTitle(longTitle), isNotNull);
    });

    test('accepts valid titles within 1-80 characters', () {
      expect(Validators.validateNoteTitle('My First Note'), isNull);
      expect(Validators.validateNoteTitle('A' * 80), isNull);
      expect(Validators.validateNoteTitle('  Trimmed Title  '), isNull);
    });
  });

  group('Validators - Note Content', () {
    test('rejects empty or whitespace-only content', () {
      expect(Validators.validateNoteContent(''), isNotNull);
      expect(Validators.validateNoteContent('   '), isNotNull);
      expect(Validators.validateNoteContent('\n\n  '), isNotNull);
      expect(Validators.validateNoteContent(null), isNotNull);
    });

    test('rejects content longer than 2000 characters', () {
      final longContent = 'C' * 2001;
      expect(Validators.validateNoteContent(longContent), isNotNull);
    });

    test('accepts valid content within 1-2000 characters', () {
      expect(Validators.validateNoteContent('Short note content'), isNull);
      expect(Validators.validateNoteContent('C' * 2000), isNull);
    });
  });
}
