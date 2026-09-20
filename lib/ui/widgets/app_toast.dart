import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppToastType { success, error, info }

class AppToast {
  /// Displays a floating, modern in-app toast notification with an icon.
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final isDark = AppColors.isDark(context);

    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case AppToastType.success:
        backgroundColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
        iconColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        iconData = Icons.check_circle_rounded;
        break;
      case AppToastType.error:
        backgroundColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2);
        iconColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        iconData = Icons.error_rounded;
        break;
      case AppToastType.info:
        backgroundColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4);
        iconColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
        iconData = Icons.info_rounded;
        break;
    }

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
