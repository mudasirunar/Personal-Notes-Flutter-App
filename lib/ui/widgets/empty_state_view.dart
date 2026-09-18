import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyStateView.noNotes({required VoidCallback onCreateNote}) {
    return EmptyStateView(
      icon: Icons.note_alt_outlined,
      title: 'No notes yet',
      description: 'Capture your thoughts, tasks, and ideas.\nTap the button below to create your first note.',
      actionLabel: 'Create a Note',
      onAction: onCreateNote,
    );
  }

  factory EmptyStateView.noSearchResults({required VoidCallback onClearFilters}) {
    return EmptyStateView(
      icon: Icons.search_off_rounded,
      title: 'No matching notes',
      description: 'We couldn’t find any notes matching your current search query or category filters.',
      actionLabel: 'Clear Filters',
      onAction: onClearFilters,
    );
  }

  factory EmptyStateView.noFavorites({required VoidCallback onViewAll}) {
    return EmptyStateView(
      icon: Icons.star_border_rounded,
      title: 'No favorite notes',
      description: 'You haven’t marked any notes as favorites yet.\nTap the star icon on any note to add it here.',
      actionLabel: 'View All Notes',
      onAction: onViewAll,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(160, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
