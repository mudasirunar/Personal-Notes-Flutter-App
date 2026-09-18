import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/note_card.dart';
import '../../widgets/skeleton_loader.dart';
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

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your notes space?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = AppColors.isDark(context);

    final filteredNotes = notesProvider.filteredNotes;
    final totalNotesCount = notesProvider.allNotes.length;
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
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingTitle,
              style: TextStyle(
                color: AppColors.textPrimaryOf(context),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userEmail,
              style: TextStyle(
                color: AppColors.textMutedOf(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondaryOf(context),
              size: 22,
            ),
            tooltip: 'Log out',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceOf(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderOf(context),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => notesProvider.setSearchQuery(val),
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: 14.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search notes by title...',
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
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Row: All/Favorites Toggle + Category Chips
                  Row(
                    children: [
                      // View Tabs: All vs Favorites
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTabChip(
                              label: 'All',
                              count: totalNotesCount,
                              isSelected: !notesProvider.favoritesOnly,
                              onTap: () => notesProvider.setFavoritesOnly(false),
                            ),
                            _buildTabChip(
                              label: 'Favorites',
                              icon: Icons.star_rounded,
                              isSelected: notesProvider.favoritesOnly,
                              onTap: () => notesProvider.setFavoritesOnly(true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Horizontal Category Filter Chips
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryFilterChip(
                                label: 'All Categories',
                                isSelected: notesProvider.selectedCategory == null,
                                onTap: () => notesProvider.setSelectedCategory(null),
                              ),
                              const SizedBox(width: 6),
                              for (final category in NoteCategory.values) ...[
                                CategoryBadge(
                                  category: category,
                                  isSelected: notesProvider.selectedCategory == category,
                                  onTap: () {
                                    if (notesProvider.selectedCategory == category) {
                                      notesProvider.setSelectedCategory(null);
                                    } else {
                                      notesProvider.setSelectedCategory(category);
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildTabChip({
    required String label,
    IconData? icon,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardSurfaceDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
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
                color: isSelected ? AppColors.favorite : AppColors.textMutedOf(context),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimaryOf(context)
                    : AppColors.textSecondaryOf(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: AppColors.textSecondaryOf(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardSurfaceDark : const Color(0xFF0F172A))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.borderOf(context),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? AppColors.textPrimaryDark : Colors.white)
                : AppColors.textSecondaryOf(context),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
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

      if (notesProvider.favoritesOnly) {
        return EmptyStateView.noFavorites(
          onViewAll: () => notesProvider.setFavoritesOnly(false),
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
