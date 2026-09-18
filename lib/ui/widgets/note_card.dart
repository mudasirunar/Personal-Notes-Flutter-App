import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/note_model.dart';
import 'category_badge.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderOf(context), width: 1),
      ),
      color: AppColors.cardSurfaceOf(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Category Badge & Favorite Star
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CategoryBadge(category: note.category),
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: note.isFavorite
                          ? AppColors.favorite
                          : (AppColors.isDark(context)
                              ? const Color(0xFF475569)
                              : AppColors.favoriteInactive),
                      size: 24,
                    ),
                    onPressed: onToggleFavorite,
                    tooltip: note.isFavorite ? 'Remove from favorites' : 'Mark as favorite',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Note Title
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimaryOf(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              // Note Content Snippet
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              // Timestamp footer
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.textMutedOf(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${DateFormatter.formatNoteDate(note.updatedAt)}',
                    style: TextStyle(
                      color: AppColors.textMutedOf(context),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
