import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class CategoryBadge extends StatelessWidget {
  final NoteCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryBadge({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (category) {
      case NoteCategory.personal:
        return isSelected ? AppColors.categoryPersonal : AppColors.categoryPersonalBg;
      case NoteCategory.work:
        return isSelected ? AppColors.categoryWork : AppColors.categoryWorkBg;
      case NoteCategory.study:
        return isSelected ? AppColors.categoryStudy : AppColors.categoryStudyBg;
    }
  }

  Color get _textColor {
    if (isSelected) return Colors.white;
    switch (category) {
      case NoteCategory.personal:
        return AppColors.categoryPersonal;
      case NoteCategory.work:
        return AppColors.categoryWork;
      case NoteCategory.study:
        return AppColors.categoryStudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : _textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 13,
            color: _textColor,
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              color: _textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }
}
