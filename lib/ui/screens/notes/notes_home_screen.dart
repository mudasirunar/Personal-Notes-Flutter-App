import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/animated_fab.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/note_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/user_profile_dialog.dart';
import 'add_edit_note_screen.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  String _lastSearchQuery = '';
  NotesFilter _lastFilter = NotesFilter.all;

  void _scrollToTop({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.offset > 0.0) {
        if (animated) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        } else {
          _scrollController.jumpTo(0.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEditNote([NoteModel? note, NoteCategory? initialCategory]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditNoteScreen(
          note: note,
          initialCategory: initialCategory,
        ),
      ),
    );
  }

  Future<String?> _deleteNote(NotesProvider notesProvider, NoteModel note) async {
    final error = await notesProvider.deleteNote(note.id);
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.errorOf(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note "${note.title.isNotEmpty ? note.title : 'Untitled'}" deleted'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    return error;
  }

  NoteCategory? _getPreselectedCategory(NotesFilter filter) {
    switch (filter) {
      case NotesFilter.personal:
        return NoteCategory.personal;
      case NotesFilter.work:
        return NoteCategory.work;
      case NotesFilter.study:
        return NoteCategory.study;
      case NotesFilter.all:
      case NotesFilter.favorites:
        return null;
    }
  }

  void _openProfileDialog({
    required String? fullName,
    required String? email,
    required String? userId,
    required List<NoteModel> allNotes,
  }) {
    final personalCount =
        allNotes.where((n) => n.category == NoteCategory.personal).length;
    final workCount =
        allNotes.where((n) => n.category == NoteCategory.work).length;
    final studyCount =
        allNotes.where((n) => n.category == NoteCategory.study).length;
    final favoriteCount = allNotes.where((n) => n.isFavorite).length;

    UserProfileDialog.show(
      context,
      fullName: fullName,
      email: email,
      userId: userId,
      totalNotes: allNotes.length,
      personalNotes: personalCount,
      workNotes: workCount,
      studyNotes: studyCount,
      favoriteNotes: favoriteCount,
      onLogoutPressed: _handleLogout,
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your notes space?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final authProvider = context.watch<AuthProvider>();

    final filteredNotes = notesProvider.filteredNotes;
    final totalNotesCount = notesProvider.allNotes.length;
    final favoriteCount =
        notesProvider.allNotes.where((n) => n.isFavorite).length;
    final personalCount = notesProvider.allNotes
        .where((n) => n.category == NoteCategory.personal)
        .length;
    final workCount = notesProvider.allNotes
        .where((n) => n.category == NoteCategory.work)
        .length;
    final studyCount = notesProvider.allNotes
        .where((n) => n.category == NoteCategory.study)
        .length;
    final displayName = authProvider.displayName;
    final firstName = authProvider.firstName;
    final userEmail = authProvider.userEmail ?? 'User';

    final greetingTitle = firstName != null && firstName.isNotEmpty
        ? "$firstName's Notes"
        : (displayName != null && displayName.isNotEmpty
            ? "$displayName's Notes"
            : 'My Notes');

    // Automatically reset scroll to top when search query or filter changes
    // so result cards start immediately below the header instead of being pushed behind it.
    if (notesProvider.searchQuery != _lastSearchQuery ||
        notesProvider.currentFilter != _lastFilter) {
      _lastSearchQuery = notesProvider.searchQuery;
      _lastFilter = notesProvider.currentFilter;
      _scrollToTop();
      if (!_isFabVisible) {
        _isFabVisible = true;
      }
    }

    final headerHeight = MediaQuery.paddingOf(context).top + 168.0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundOf(context),
      body: Stack(
        children: [
          // 1. Content Feed & States (underneath translucent header)
          Positioned.fill(
            child: _buildContent(notesProvider, filteredNotes, headerHeight),
          ),

          // 2. Translucent Frosted Glass Header (Avatar, Name, Email, Search Bar, Filter Chips)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTranslucentHeader(
              context: context,
              notesProvider: notesProvider,
              authProvider: authProvider,
              greetingTitle: greetingTitle,
              userEmail: userEmail,
              displayName: displayName,
              totalNotesCount: totalNotesCount,
              favoriteCount: favoriteCount,
              personalCount: personalCount,
              workCount: workCount,
              studyCount: studyCount,
            ),
          ),
        ],
      ),
      floatingActionButton: filteredNotes.isEmpty
          ? null
          : AnimatedFab(
              isVisible: _isFabVisible,
              onPressed: () => _openAddEditNote(
                null,
                _getPreselectedCategory(notesProvider.currentFilter),
              ),
            ),
    );
  }

  Widget _buildTranslucentHeader({
    required BuildContext context,
    required NotesProvider notesProvider,
    required AuthProvider authProvider,
    required String greetingTitle,
    required String userEmail,
    required String? displayName,
    required int totalNotesCount,
    required int favoriteCount,
    required int personalCount,
    required int workCount,
    required int studyCount,
  }) {
    final isDark = AppColors.isDark(context);
    final safeArea = MediaQuery.paddingOf(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {}, // Blocks touches from bleeding through to note cards behind
          child: Container(
            decoration: BoxDecoration(
              // Perfectly matches scaffold background tone with frosted translucency
              color: AppColors.scaffoldBackgroundOf(context).withValues(
                alpha: isDark ? 0.60 : 0.66,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.15 : 0.03,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Profile & Greeting Row (Avatar, Name, Email)
                    Row(
                      children: [
                        UserAvatar(
                          name: displayName,
                          email: userEmail,
                          userId: authProvider.userId,
                          size: 42,
                          isLoading: !authProvider.isInitialized,
                          onTap: () => _openProfileDialog(
                            fullName: displayName,
                            email: userEmail,
                            userId: authProvider.userId,
                            allNotes: notesProvider.allNotes,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                greetingTitle,
                                style: TextStyle(
                                  color: AppColors.textPrimaryOf(context),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  color: AppColors.textMutedOf(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Translucent Search Input Field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _scrollToTop();
                        notesProvider.setSearchQuery(val);
                      },
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: 14.5,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? AppColors.cardSurfaceDark.withValues(alpha: 0.60)
                            : AppColors.cardSurface.withValues(alpha: 0.85),
                        hintText: 'Search notes...',
                        hintStyle: TextStyle(
                          color: AppColors.textMutedOf(context),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textMutedOf(context),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textMutedOf(context),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _scrollToTop();
                                  _searchController.clear();
                                  notesProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.borderOf(context).withValues(
                              alpha: isDark ? 0.35 : 0.60,
                            ),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.borderOf(context).withValues(
                              alpha: isDark ? 0.35 : 0.60,
                            ),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horizontal Filter Chips: All, Favorites, Personal, Work, Study
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            count: totalNotesCount,
                            color: AppColors.primary,
                            isSelected: notesProvider.currentFilter == NotesFilter.all,
                            onTap: () => notesProvider.setFilter(NotesFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Favorites',
                            icon: Icons.star_rounded,
                            count: favoriteCount,
                            color: AppColors.favorite,
                            isSelected: notesProvider.currentFilter == NotesFilter.favorites,
                            onTap: () => notesProvider.setFilter(NotesFilter.favorites),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Personal',
                            icon: NoteCategory.personal.icon,
                            count: personalCount,
                            color: AppColors.categoryPersonal,
                            isSelected: notesProvider.currentFilter == NotesFilter.personal,
                            onTap: () => notesProvider.setFilter(NotesFilter.personal),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Work',
                            icon: NoteCategory.work.icon,
                            count: workCount,
                            color: AppColors.categoryWork,
                            isSelected: notesProvider.currentFilter == NotesFilter.work,
                            onTap: () => notesProvider.setFilter(NotesFilter.work),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Study',
                            icon: NoteCategory.study.icon,
                            count: studyCount,
                            color: AppColors.categoryStudy,
                            isSelected: notesProvider.currentFilter == NotesFilter.study,
                            onTap: () => notesProvider.setFilter(NotesFilter.study),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderOf(context).withValues(
                alpha: isDark ? 0.35 : 0.55,
              ),
              indent: 16 + safeArea.left,
              endIndent: 16 + safeArea.right,
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required int count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);
    // Colors of chips are identical irrespective of theme in both light and dark modes
    final chipColor = color;
    final unselectedBg = isDark
        ? chipColor.withValues(alpha: 0.14)
        : chipColor.withValues(alpha: 0.08);
    final unselectedBorder = chipColor.withValues(alpha: isDark ? 0.35 : 0.28);

    return GestureDetector(
      key: ValueKey('filter_chip_${label.toLowerCase()}'),
      onTap: () {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
        }
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : unselectedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : unselectedBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.28)
                    : chipColor.withValues(alpha: isDark ? 0.20 : 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : chipColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    NotesProvider notesProvider,
    List<NoteModel> filteredNotes,
    double headerHeight,
  ) {
    // 1. Initial skeleton loading state
    if (notesProvider.isLoading && notesProvider.allNotes.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: headerHeight),
        child: const NotesListSkeleton(count: 4),
      );
    }

    // 2. Error state
    if (notesProvider.errorMessage != null && notesProvider.allNotes.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.errorOf(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load notes',
                style: TextStyle(
                  color: AppColors.textPrimaryOf(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                notesProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => notesProvider.retry(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Contextual empty states
    if (filteredNotes.isEmpty) {
      Widget emptyWidget;
      if (notesProvider.searchQuery.trim().isNotEmpty) {
        emptyWidget = EmptyStateView.noSearchResults(
          query: notesProvider.searchQuery,
          onClearSearch: () {
            _scrollToTop();
            _searchController.clear();
            notesProvider.setSearchQuery('');
          },
        );
      } else if (notesProvider.currentFilter == NotesFilter.favorites) {
        emptyWidget = EmptyStateView.noFavorites(
          onViewAll: () => notesProvider.setFilter(NotesFilter.all),
        );
      } else if (notesProvider.currentFilter == NotesFilter.personal) {
        emptyWidget = EmptyStateView.noPersonalNotes(
          onCreateNote: () => _openAddEditNote(null, NoteCategory.personal),
        );
      } else if (notesProvider.currentFilter == NotesFilter.work) {
        emptyWidget = EmptyStateView.noWorkNotes(
          onCreateNote: () => _openAddEditNote(null, NoteCategory.work),
        );
      } else if (notesProvider.currentFilter == NotesFilter.study) {
        emptyWidget = EmptyStateView.noStudyNotes(
          onCreateNote: () => _openAddEditNote(null, NoteCategory.study),
        );
      } else {
        emptyWidget = EmptyStateView.noNotes(
          onCreateNote: () => _openAddEditNote(),
        );
      }

      return SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: headerHeight),
          child: emptyWidget,
        ),
      );
    }

    // 4. Feed of notes
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        // Only trigger slide down/up if the screen content is actually scrollable (> 40px overflow)
        if (notification.metrics.maxScrollExtent > 40) {
          if (notification.direction == ScrollDirection.reverse) {
            // User scrolled down -> smoothly hide FAB
            if (_isFabVisible) {
              setState(() => _isFabVisible = false);
            }
          } else if (notification.direction == ScrollDirection.forward) {
            // User scrolled up -> smoothly reveal FAB
            if (!_isFabVisible) {
              setState(() => _isFabVisible = true);
            }
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(top: headerHeight + 6, bottom: 80),
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          final showCategory = notesProvider.currentFilter == NotesFilter.all ||
              notesProvider.currentFilter == NotesFilter.favorites;
          return NoteCard(
            key: ValueKey(note.id),
            note: note,
            showCategory: showCategory,
            isInsideFavoritesFilter:
                notesProvider.currentFilter == NotesFilter.favorites,
            showDivider: index < filteredNotes.length - 1,
            onTap: () => _openAddEditNote(note),
            onToggleFavorite: () => notesProvider.toggleFavorite(note),
            onDelete: () => _deleteNote(notesProvider, note),
          );
        },
      ),
    );
  }
}
