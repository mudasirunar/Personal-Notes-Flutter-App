import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    NoteCategory? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safely parse timestamps handling unresolved local server timestamps
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    }

    return NoteModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      category: NoteCategory.fromString(data['category'] as String?),
      isFavorite: data['isFavorite'] as bool? ?? false,
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(data['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Map for creating a new note (sets both createdAt & updatedAt to serverTimestamp)
  Map<String, dynamic> toFirestoreForCreate() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'category': category.name,
      'isFavorite': isFavorite,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Map for updating an existing note (preserves original createdAt, updates updatedAt)
  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'category': category.name,
      'isFavorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          category == other.category &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      isFavorite.hashCode;
}
