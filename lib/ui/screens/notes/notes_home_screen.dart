import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEditNote([NoteModel? note]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );
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

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundOf(context),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
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
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search Bar & Filter Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => notesProvider.setSearchQuery(val),
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontSize: 14.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardSurfaceOf(context),
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
                                _searchController.clear();
                                notesProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.borderOf(context),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.borderOf(context),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Filter Chips: All, Favorites, Personal, Work, Study
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // ── 1. All (Primary theme color, no icon) ──
                        _buildFilterChip(
                          label: 'All',
                          count: totalNotesCount,
                          color: AppColors.primary,
                          isSelected: notesProvider.currentFilter == NotesFilter.all,
                          onTap: () => notesProvider.setFilter(NotesFilter.all),
                        ),
                        const SizedBox(width: 8),

                        // ── 2. Favorites (Amber color, star icon) ──
                        _buildFilterChip(
                          label: 'Favorites',
                          icon: Icons.star_rounded,
                          count: favoriteCount,
                          color: AppColors.favorite,
                          isSelected: notesProvider.currentFilter == NotesFilter.favorites,
                          onTap: () => notesProvider.setFilter(NotesFilter.favorites),
                        ),
                        const SizedBox(width: 8),

                        // ── 3. Personal (Violet color, person icon) ──
                        _buildFilterChip(
                          label: 'Personal',
                          icon: NoteCategory.personal.icon,
                          count: personalCount,
                          color: AppColors.categoryPersonal,
                          isSelected: notesProvider.currentFilter == NotesFilter.personal,
                          onTap: () => notesProvider.setFilter(NotesFilter.personal),
                        ),
                        const SizedBox(width: 8),

                        // ── 4. Work (Royal Blue color, work icon) ──
                        _buildFilterChip(
                          label: 'Work',
                          icon: NoteCategory.work.icon,
                          count: workCount,
                          color: AppColors.categoryWork,
                          isSelected: notesProvider.currentFilter == NotesFilter.work,
                          onTap: () => notesProvider.setFilter(NotesFilter.work),
                        ),
                        const SizedBox(width: 8),

                        // ── 5. Study (Emerald color, book icon) ──
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

            // Feed Content
            Expanded(
              child: _buildContent(notesProvider, filteredNotes),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditNote(),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New Note',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
      onTap: onTap,
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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

  Widget _buildContent(NotesProvider notesProvider, List<NoteModel> filteredNotes) {
    // 1. Initial skeleton loading state
    if (notesProvider.isLoading && notesProvider.allNotes.isEmpty) {
      return const NotesListSkeleton(count: 4);
    }

    // 2. Error state
    if (notesProvider.errorMessage != null && notesProvider.allNotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
      if (notesProvider.searchQuery.trim().isNotEmpty) {
        return EmptyStateView.noSearchResults(
          onClearFilters: () {
            _searchController.clear();
            notesProvider.clearFilters();
          },
        );
      }

      if (notesProvider.currentFilter == NotesFilter.favorites) {
        return EmptyStateView.noFavorites(
          onViewAll: () => notesProvider.setFilter(NotesFilter.all),
        );
      }

      return EmptyStateView.noNotes(
        onCreateNote: () => _openAddEditNote(),
      );
    }

    // 4. Feed of notes
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return NoteCard(
          key: ValueKey(note.id),
          note: note,
          onTap: () => _openAddEditNote(note),
          onToggleFavorite: () => notesProvider.toggleFavorite(note),
        );
      },
    );
  }
}
