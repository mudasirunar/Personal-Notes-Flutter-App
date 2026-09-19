import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'user_avatar.dart';

/// Modal dialog displaying user profile information, note statistics,
/// and a red logout button.
class UserProfileDialog extends StatelessWidget {
  final String? fullName;
  final String? email;
  final String? userId;
  final int totalNotes;
  final int personalNotes;
  final int workNotes;
  final int studyNotes;
  final int favoriteNotes;
  final VoidCallback onLogoutPressed;

  const UserProfileDialog({
    super.key,
    required this.fullName,
    required this.email,
    required this.userId,
    required this.totalNotes,
    required this.personalNotes,
    required this.workNotes,
    required this.studyNotes,
    required this.favoriteNotes,
    required this.onLogoutPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String? fullName,
    required String? email,
    required String? userId,
    required int totalNotes,
    required int personalNotes,
    required int workNotes,
    required int studyNotes,
    required int favoriteNotes,
    required VoidCallback onLogoutPressed,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => UserProfileDialog(
        fullName: fullName,
        email: email,
        userId: userId,
        totalNotes: totalNotes,
        personalNotes: personalNotes,
        workNotes: workNotes,
        studyNotes: studyNotes,
        favoriteNotes: favoriteNotes,
        onLogoutPressed: () {
          Navigator.of(ctx).pop();
          onLogoutPressed();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape || mediaQuery.size.height < 520;
    final isDark = AppColors.isDark(context);
    final cardBg = AppColors.cardSurfaceOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);

    final displayName = (fullName != null && fullName!.trim().isNotEmpty)
        ? fullName!.trim()
        : 'Notes User';

    final avatarSize = isLandscape ? 56.0 : 72.0;
    final avatarRadius = BorderRadius.circular(isLandscape ? 16 : 20);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isLandscape ? 12 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: mediaQuery.size.height * 0.90,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              isLandscape ? 10 : 16,
              20,
              isLandscape ? 14 : 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Bar with Close (X) button ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: textMuted),
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                // ── Top Center Avatar ──
                Center(
                  child: UserAvatar(
                    name: displayName,
                    email: email,
                    userId: userId,
                    size: avatarSize,
                    borderRadius: avatarRadius,
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 14),

                // ── Full Name ──
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: isLandscape ? 17 : 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),

                // ── Subtitle-style Email ──
                if (email != null && email!.isNotEmpty)
                  Text(
                    email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                SizedBox(height: isLandscape ? 12 : 18),

              // ── Divider ──
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 14),

              // ── Notes Overview Section ──
              Row(
                children: [
                  Text(
                    'NOTES SUMMARY',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalNotes total',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Category & Favorite Stat Cards ──
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: NoteCategory.personal.label,
                      count: personalNotes,
                      icon: NoteCategory.personal.icon,
                      color: isDark ? const Color(0xFF818CF8) : AppColors.categoryPersonal,
                      bgColor: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.categoryPersonalBg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: NoteCategory.work.label,
                      count: workNotes,
                      icon: NoteCategory.work.icon,
                      color: isDark ? const Color(0xFFFBBF24) : AppColors.categoryWork,
                      bgColor: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.categoryWorkBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: NoteCategory.study.label,
                      count: studyNotes,
                      icon: NoteCategory.study.icon,
                      color: isDark ? const Color(0xFF34D399) : AppColors.categoryStudy,
                      bgColor: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.categoryStudyBg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Favorites',
                      count: favoriteNotes,
                      icon: Icons.star_rounded,
                      color: AppColors.favorite,
                      bgColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFFEF9C3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Red Log Out Button ──
              ElevatedButton.icon(
                onPressed: onLogoutPressed,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final textPrimary = AppColors.textPrimaryOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
