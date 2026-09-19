import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/error_mapper.dart';
import '../data/models/note_model.dart';
import '../data/services/analytics_service.dart';
import '../data/services/notes_service.dart';

enum NotesFilter {
  all,
  favorites,
  personal,
  work,
  study,
}

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService;
  final AnalyticsService _analyticsService;
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  String? _currentUserId;
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Single mutually-exclusive active filter and Search
  String _searchQuery = '';
  NotesFilter _currentFilter = NotesFilter.all;
  bool _favoritesOnly = false;
  NoteCategory? _selectedCategory;

  // Single-action busy state (saving / deleting)
  bool _isSaving = false;

  NotesProvider({
    NotesService? notesService,
    AnalyticsService? analyticsService,
  })  : _notesService = notesService ?? NotesService(),
        _analyticsService = analyticsService ?? AnalyticsService();

  List<NoteModel> get allNotes => _notes;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  NotesFilter get currentFilter => _currentFilter;
  bool get favoritesOnly => _favoritesOnly;
  NoteCategory? get selectedCategory => _selectedCategory;

  /// Combined filter: Single active filter (all / fav / category) + search query
  /// When search query is active, results are intelligently sorted by relevance:
  /// - Title matches appear before description matches
  /// - Prefix/word-start matches appear before substring matches
  /// - Alphabetical tie-breaking for equal relevance
  List<NoteModel> get filteredNotes {
    final filtered = _notes.where((note) {
      // 1. Single active filter check
      switch (_currentFilter) {
        case NotesFilter.all:
          break;
        case NotesFilter.favorites:
          if (!note.isFavorite) return false;
          break;
        case NotesFilter.personal:
          if (note.category != NoteCategory.personal) return false;
          break;
        case NotesFilter.work:
          if (note.category != NoteCategory.work) return false;
          break;
        case NotesFilter.study:
          if (note.category != NoteCategory.study) return false;
          break;
      }

      // 2. Search query check (case-insensitive on both title and description/content)
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesContent = note.content.toLowerCase().contains(query);
        if (!matchesTitle && !matchesContent) {
          return false;
        }
      }

      return true;
    }).toList();

    // 3. Relevance ranking and sorting when search query is active
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered.sort((a, b) {
        final scoreA = _searchRelevanceScore(a, query);
        final scoreB = _searchRelevanceScore(b, query);
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA); // Higher relevance score first
        }
        // Tie-breaker 1: Alphabetical by title
        final titleCompare = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        if (titleCompare != 0) {
          return titleCompare;
        }
        // Tie-breaker 2: Newest updated first
        final timeA = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA);
      });
    }

    return filtered;
  }

  /// Calculates search relevance score for a note.
  /// Higher score means higher priority in search results.
  ///
  /// Ranking order:
  /// 1. Exact title match (1000)
  /// 2. Title starts with query (900)
  /// 3. Title contains a word starting with query (800)
  /// 4. Title contains query anywhere (700 - position index)
  /// 5. Description/Content starts with query (500)
  /// 6. Description/Content contains word starting with query (400)
  /// 7. Description/Content contains query anywhere (300 - position index)
  int _searchRelevanceScore(NoteModel note, String query) {
    final title = note.title.toLowerCase();
    final content = note.content.toLowerCase();
    final wordBoundaryPattern = RegExp(r'\b' + RegExp.escape(query));

    // 1. Exact title match
    if (title == query) return 1000;

    // 2. Title starts with query
    if (title.startsWith(query)) return 900;

    // 3. Title contains word starting with query (e.g. "Sprint Planning" or "(Study)" for "plan" / "stud")
    if (wordBoundaryPattern.hasMatch(title)) return 800;

    // 4. Title contains query anywhere (earlier in title gets higher priority)
    if (title.contains(query)) {
      final index = title.indexOf(query);
      return 700 - index.clamp(0, 100);
    }

    // 5. Content starts with query
    if (content.startsWith(query)) return 500;

    // 6. Content contains word starting with query
    if (wordBoundaryPattern.hasMatch(content)) return 400;

    // 7. Content contains query anywhere (earlier in content gets higher priority)
    if (content.contains(query)) {
      final index = content.indexOf(query);
      return 300 - index.clamp(0, 100);
    }

    return 0;
  }

  /// Called when the authenticated user changes.
  /// Strictly isolates user data by canceling any active stream and wiping memory.
  void updateUser(String? newUserId) {
    if (newUserId == _currentUserId) return;

    // 1. Immediate listener cancellation
    _notesSubscription?.cancel();
    _notesSubscription = null;

    // 2. Immediate synchronous data wipe to avoid any state leakage
    _notes = [];
    _searchQuery = '';
    _currentFilter = NotesFilter.all;
    _favoritesOnly = false;
    _selectedCategory = null;
    _errorMessage = null;
    _isSaving = false;

    _currentUserId = newUserId;

    if (newUserId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 3. Start stream for new authenticated user
    _isLoading = true;
    notifyListeners();

    _listenToNotes(newUserId);
  }

  void _listenToNotes(String userId) {
    _notesSubscription = _notesService.getNotesStream(userId).listen(
      (notesList) {
        _notes = notesList;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (dynamic error) {
        _isLoading = false;
        _errorMessage = ErrorMapper.mapFirestoreError(error);
        notifyListeners();
      },
    );
  }

  void retry() {
    if (_currentUserId != null) {
      _notesSubscription?.cancel();
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      _listenToNotes(_currentUserId!);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(NotesFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    _favoritesOnly = filter == NotesFilter.favorites;
    _selectedCategory = switch (filter) {
      NotesFilter.personal => NoteCategory.personal,
      NotesFilter.work => NoteCategory.work,
      NotesFilter.study => NoteCategory.study,
      _ => null,
    };
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    setFilter(value ? NotesFilter.favorites : NotesFilter.all);
  }

  void setSelectedCategory(NoteCategory? category) {
    if (category == null) {
      setFilter(NotesFilter.all);
    } else {
      switch (category) {
        case NoteCategory.personal:
          setFilter(NotesFilter.personal);
          break;
        case NoteCategory.work:
          setFilter(NotesFilter.work);
          break;
        case NoteCategory.study:
          setFilter(NotesFilter.study);
          break;
      }
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _currentFilter = NotesFilter.all;
    _favoritesOnly = false;
    _selectedCategory = null;
    notifyListeners();
  }

  /// Create a new note. Returns null on success or error message on failure.
  /// Preserves input by only returning error string on failure.
  Future<String?> createNote({
    required String title,
    required String content,
    required NoteCategory category,
    bool isFavorite = false,
  }) async {
    if (_currentUserId == null) {
      return 'User session not found. Please log in again.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      final note = NoteModel(
        id: '',
        title: title,
        content: content,
        category: category,
        isFavorite: isFavorite,
      );

      await _notesService.createNote(
        userId: _currentUserId!,
        note: note,
      );

      await _analyticsService.logNoteCreated(category: category.name);

      _isSaving = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return ErrorMapper.mapFirestoreError(e);
    }
  }

  /// Update an existing note. Returns null on success or error message on failure.
  Future<String?> updateNote(NoteModel note) async {
    if (_currentUserId == null) {
      return 'User session not found. Please log in again.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _notesService.updateNote(
        userId: _currentUserId!,
        note: note,
      );

      await _analyticsService.logNoteUpdated(category: note.category.name);

      _isSaving = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return ErrorMapper.mapFirestoreError(e);
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(NoteModel note) async {
    if (_currentUserId == null) return;

    try {
      await _notesService.toggleFavorite(
        userId: _currentUserId!,
        noteId: note.id,
        currentStatus: note.isFavorite,
      );
      await _analyticsService.logFavoriteToggled(isFavorite: !note.isFavorite);
    } catch (e) {
      // Stream will automatically keep UI consistent
    }
  }

  /// Delete note
  Future<String?> deleteNote(String noteId) async {
    if (_currentUserId == null) {
      return 'User session not found. Please log in again.';
    }

    try {
      await _notesService.deleteNote(
        userId: _currentUserId!,
        noteId: noteId,
      );
      await _analyticsService.logNoteDeleted();
      return null; // Success
    } catch (e) {
      return ErrorMapper.mapFirestoreError(e);
    }
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
