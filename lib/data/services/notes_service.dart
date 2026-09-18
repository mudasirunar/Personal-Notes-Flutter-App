import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/note_model.dart';

class NotesService {
  final FirebaseFirestore? _firestoreInstance;

  NotesService({FirebaseFirestore? firestore})
      : _firestoreInstance = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userNotesCollection(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notesSubcollection);
  }

  /// Real-time stream of user's notes ordered by newest updated first
  Stream<List<NoteModel>> getNotesStream(String userId) {
    return _userNotesCollection(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    });
  }

  /// Create a new note using server timestamp
  Future<String> createNote({
    required String userId,
    required NoteModel note,
  }) async {
    final docRef = await _userNotesCollection(userId).add(
      note.toFirestoreForCreate(),
    );
    return docRef.id;
  }

  /// Update an existing note preserving createdAt
  Future<void> updateNote({
    required String userId,
    required NoteModel note,
  }) async {
    await _userNotesCollection(userId).doc(note.id).update(
      note.toFirestoreForUpdate(),
    );
  }

  /// Toggle favorite status of a note
  Future<void> toggleFavorite({
    required String userId,
    required String noteId,
    required bool currentStatus,
  }) async {
    await _userNotesCollection(userId).doc(noteId).update({
      'isFavorite': !currentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete note permanently
  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    await _userNotesCollection(userId).doc(noteId).delete();
  }
}
