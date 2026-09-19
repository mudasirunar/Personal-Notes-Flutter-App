import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final Color? accentColor;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.accentColor,
  });

  /// Overall zero notes state
  factory EmptyStateView.noNotes({required VoidCallback onCreateNote}) {
    return EmptyStateView(
      icon: Icons.note_add_outlined,
      accentColor: AppColors.primary,
      title: 'No notes yet',
      description: 'Capture your thoughts, ideas, and daily tasks.\nTap below to create your very first note!',
      actionLabel: 'Create a Note',
      actionIcon: Icons.add_rounded,
      onAction: onCreateNote,
    );
  }

  /// Search query with zero results
  factory EmptyStateView.noSearchResults({
    String? query,
    required VoidCallback onClearSearch,
  }) {
    final queryText = (query != null && query.trim().isNotEmpty)
        ? ' matching "${query.trim()}"'
        : '';
    return EmptyStateView(
      icon: Icons.search_off_rounded,
      accentColor: AppColors.primary,
      title: 'No matching notes',
      description: 'We couldn’t find any notes$queryText.\nCheck your spelling or try searching different keywords.',
      actionLabel: 'Clear Search',
      actionIcon: Icons.close_rounded,
      onAction: onClearSearch,
    );
  }

  /// Favorites filter with zero items
  factory EmptyStateView.noFavorites({required VoidCallback onViewAll}) {
    return EmptyStateView(
      icon: Icons.star_outline_rounded,
      accentColor: AppColors.favorite,
      title: 'No favorite notes yet',
      description: 'Star important notes to keep them handy\nand easily accessible right here anytime.',
      actionLabel: 'Explore All Notes',
      actionIcon: Icons.explore_outlined,
      onAction: onViewAll,
    );
  }

  /// Personal category filter with zero items
  factory EmptyStateView.noPersonalNotes({required VoidCallback onCreateNote}) {
    return EmptyStateView(
      icon: Icons.person_outline_rounded,
      accentColor: AppColors.categoryPersonal,
      title: 'No personal notes yet',
      description: 'Keep your personal journal, daily thoughts,\nroutines, and private reminders organized here.',
      actionLabel: 'Add Personal Note',
      actionIcon: Icons.add_rounded,
      onAction: onCreateNote,
    );
  }

  /// Work category filter with zero items
  factory EmptyStateView.noWorkNotes({required VoidCallback onCreateNote}) {
    return EmptyStateView(
      icon: Icons.work_outline_rounded,
      accentColor: AppColors.categoryWork,
      title: 'No work notes yet',
      description: 'Track projects, meeting minutes, action items,\nand work milestones all in one place.',
      actionLabel: 'Add Work Note',
      actionIcon: Icons.add_rounded,
      onAction: onCreateNote,
    );
  }

  /// Study category filter with zero items
  factory EmptyStateView.noStudyNotes({required VoidCallback onCreateNote}) {
    return EmptyStateView(
      icon: Icons.school_outlined,
      accentColor: AppColors.categoryStudy,
      title: 'No study notes yet',
      description: 'Save lecture takeaways, reading summaries,\nkey research, and study guides for easy review.',
      actionLabel: 'Add Study Note',
      actionIcon: Icons.add_rounded,
      onAction: onCreateNote,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final color = accentColor ?? AppColors.primary;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 48 : 32,
          vertical: isLandscape ? 16 : 36,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container with layered aura
            Container(
              width: isLandscape ? 60 : 76,
              height: isLandscape ? 60 : 76,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.16 : 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.35 : 0.22),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: isLandscape ? 30 : 36,
                color: color,
              ),
            ),
            SizedBox(height: isLandscape ? 12 : 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimaryOf(context),
                fontSize: isLandscape ? 16.5 : 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: isLandscape ? 6 : 8),

            // Description
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isLandscape ? 440 : 340),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: isLandscape ? 13 : 13.5,
                  height: 1.45,
                ),
              ),
            ),

            // Tailored CTA button - constrained & centered to prevent stretching in landscape
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isLandscape ? 16 : 22),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 140,
                    maxWidth: isLandscape ? 220 : 260,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: actionIcon != null
                        ? Icon(actionIcon, size: 17, color: Colors.white)
                        : const SizedBox.shrink(),
                    label: Text(
                      actionLabel!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 1.5,
                      shadowColor: color.withValues(alpha: 0.35),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: isLandscape ? 9 : 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
