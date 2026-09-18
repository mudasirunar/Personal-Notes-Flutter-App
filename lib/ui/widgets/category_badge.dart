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

  Color _categoryBaseColor(bool isDark) {
    switch (category) {
      case NoteCategory.personal:
        return isDark ? const Color(0xFF818CF8) : AppColors.categoryPersonal;
      case NoteCategory.work:
        return isDark ? const Color(0xFFFBBF24) : AppColors.categoryWork;
      case NoteCategory.study:
        return isDark ? const Color(0xFF34D399) : AppColors.categoryStudy;
    }
  }

  Color _backgroundColor(bool isDark) {
    if (isSelected) return _categoryBaseColor(isDark);
    if (isDark) return _categoryBaseColor(isDark).withValues(alpha: 0.15);
    switch (category) {
      case NoteCategory.personal:
        return AppColors.categoryPersonalBg;
      case NoteCategory.work:
        return AppColors.categoryWorkBg;
      case NoteCategory.study:
        return AppColors.categoryStudyBg;
    }
  }

  Color _textColor(bool isDark) {
    if (isSelected) return Colors.white;
    return _categoryBaseColor(isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textColor = _textColor(isDark);
    final backgroundColor = _backgroundColor(isDark);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 13,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              color: textColor,
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
