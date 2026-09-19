import 'package:flutter/material.dart';
import '../../core/utils/avatar_utils.dart';

/// WhatsApp-style profile avatar widget.
/// Displays a colored rounded box with the user's initials centered,
/// or a subtle spinner when loading profile details from Firebase.
class UserAvatar extends StatelessWidget {
  final String? name;
  final String? email;
  final String? userId;
  final double size;
  final bool isLoading;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const UserAvatar({
    super.key,
    this.name,
    this.email,
    this.userId,
    this.size = 40,
    this.isLoading = false,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.28);
    final bgColor = AvatarUtils.getColorForUser(userId, email);
    final initials = AvatarUtils.getInitials(name, email);
    final textColor = AvatarUtils.getContrastingTextColor(bgColor);

    Widget content;
    if (isLoading) {
      content = Center(
        child: SizedBox(
          width: size * 0.44,
          height: size * 0.44,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    } else {
      content = Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      );
    }

    final avatarBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: avatarBox,
        ),
      );
    }

    return avatarBox;
  }
}
