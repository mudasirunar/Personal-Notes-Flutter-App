import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/note_model.dart';
import 'category_badge.dart';
import 'delete_note_dialog.dart';

class NoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;
  final bool showCategory;
  final bool isInsideFavoritesFilter;
  final bool showDivider;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
    this.showCategory = true,
    this.isInsideFavoritesFilter = false,
    this.showDivider = true,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _exitController;
  Animation<Offset>? _exitSlideAnimation;
  Animation<double>? _exitFadeAnimation;
  Animation<double>? _exitCollapseAnimation;

  // Holds frozen favorite status during swipe snap-back to prevent background color glitch
  bool? _frozenSwipeFavorite;

  void _initExitController() {
    if (_exitController != null) return;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _exitController = controller;

    // Phase 1: Card smoothly swipes horizontally off-screen and fades
    _exitSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeInOutCubic),
      ),
    );

    _exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeIn),
      ),
    );

    // Phase 2: Vertical collapse so below cards slide smoothly up into place
    _exitCollapseAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.40, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initExitController();
  }

  @override
  void dispose() {
    _exitController?.dispose();
    super.dispose();
  }

  Future<void> _animateExitAndRun(VoidCallback callback) async {
    if (!mounted) return;
    _initExitController();
    await _exitController?.forward();
    if (mounted) {
      callback();
    }
  }

  void _handleToggleFavorite() {
    // When unfavoriting from the Favorites filter, play horizontal slide-out
    // and vertical collapse so below cards smoothly glide up!
    if (widget.isInsideFavoritesFilter && widget.note.isFavorite) {
      _animateExitAndRun(widget.onToggleFavorite);
    } else {
      widget.onToggleFavorite();
    }
  }

  @override
  Widget build(BuildContext context) {
    _initExitController();
    final isDark = AppColors.isDark(context);
    final safeArea = MediaQuery.paddingOf(context);

    Widget cardContent = Dismissible(
            key: ValueKey('dismissible_${widget.note.id}'),
            // Swipe left-to-right: Favorite / Unfavorite
            // Swipe right-to-left: Delete (gesture only, keeps card minimal)
            direction: widget.onDelete != null
                ? DismissDirection.horizontal
                : DismissDirection.startToEnd,
            dismissThresholds: const {
              DismissDirection.startToEnd: 0.25,
              DismissDirection.endToStart: 0.25,
            },
            background: _buildSwipeActionBackground(
              isFavorite: _frozenSwipeFavorite ?? widget.note.isFavorite,
              isLeading: true,
              safeArea: safeArea,
            ),
            secondaryBackground: _buildSwipeActionBackground(
              isFavorite: _frozenSwipeFavorite ?? widget.note.isFavorite,
              isLeading: false,
              safeArea: safeArea,
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Swipe to favorite / unfavorite
                HapticFeedback.lightImpact();

                // If in favorites category and unfavoriting, smoothly dismiss and slide below cards up
                if (widget.isInsideFavoritesFilter && widget.note.isFavorite) {
                  return true;
                }

                // Freeze swipe background state so it does NOT jump while card is snapping back
                setState(() {
                  _frozenSwipeFavorite = widget.note.isFavorite;
                });

                // Let card settle completely into its closed position before updating state
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    widget.onToggleFavorite();
                    setState(() {
                      _frozenSwipeFavorite = null;
                    });
                  }
                });

                return false; // Snap back smoothly; do not dismiss card
              } else if (direction == DismissDirection.endToStart) {
                // Swipe to delete -> prompt confirmation dialog
                final confirmed = await DeleteNoteDialog.show(
                  context,
                  noteTitle: widget.note.title,
                );
                // Returning true triggers Dismissible's smooth horizontal slide-out
                // and vertical height collapse before onDismissed is called
                return confirmed == true;
              }
              return false;
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart && widget.onDelete != null) {
                widget.onDelete!();
              } else if (direction == DismissDirection.startToEnd &&
                  widget.isInsideFavoritesFilter &&
                  widget.note.isFavorite) {
                widget.onToggleFavorite();
              }
            },
            child: Container(
              color: AppColors.scaffoldBackgroundOf(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 + safeArea.left,
                          12,
                          16 + safeArea.right,
                          12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Row: Category chip & Favorite star button right beside it
                            Row(
                              children: [
                                if (widget.showCategory) ...[
                                  CategoryBadge(category: widget.note.category),
                                  const SizedBox(width: 8),
                                ],
                                _FavoriteButton(
                                  isFavorite: widget.note.isFavorite,
                                  onPressed: _handleToggleFavorite,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Full-width Note Title
                            Text(
                              widget.note.title.isNotEmpty
                                  ? widget.note.title
                                  : 'Untitled Note',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimaryOf(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                height: 1.25,
                              ),
                            ),

                            // Full-width Note Content Preview (only rendered if present)
                            if (widget.note.content.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.note.content.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondaryOf(context),
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),

                            // Footer: Updated timestamp (minimal, uncluttered)
                            Text(
                              'Updated ${DateFormatter.formatNoteDate(widget.note.updatedAt)}',
                              style: TextStyle(
                                color: AppColors.textMutedOf(context),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.showDivider)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? const Color(0x1FFFFFFF)
                          : AppColors.borderOf(context).withValues(alpha: 0.8),
                      indent: 16 + safeArea.left,
                      endIndent: 16 + safeArea.right,
                    ),
                ],
              ),
            ),
          );

    if (_exitCollapseAnimation != null &&
        _exitSlideAnimation != null &&
        _exitFadeAnimation != null) {
      return SizeTransition(
        sizeFactor: _exitCollapseAnimation!,
        axis: Axis.vertical,
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _exitSlideAnimation!,
          child: FadeTransition(
            opacity: _exitFadeAnimation!,
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }

  /// Builds swipe background with appropriate colors and icons:
  /// - Left-to-Right: Amber when favoriting, Slate Grey when unfavoriting
  /// - Right-to-Left: Crimson Red with sweep icon when deleting
  Widget _buildSwipeActionBackground({
    required bool isFavorite,
    required bool isLeading,
    required EdgeInsets safeArea,
  }) {
    if (isLeading) {
      final bgColor =
          isFavorite ? AppColors.swipeUnfavorite : AppColors.swipeFavorite;
      final icon =
          isFavorite ? Icons.star_border_rounded : Icons.star_rounded;
      final label = isFavorite ? 'Unfavorite' : 'Favorite';

      return Container(
        padding: EdgeInsets.only(
          left: 20 + safeArea.left,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20 + safeArea.right,
        ),
        decoration: const BoxDecoration(
          color: AppColors.swipeDelete,
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 22),
          ],
        ),
      );
    }
  }
}

/// A dedicated button for the favorite star icon with a tactile scale-bounce animation
class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _scaleController;
  Animation<double>? _scaleAnimation;

  void _initScaleController() {
    if (_scaleController != null) return;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleController = controller;
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 50,
      ),
    ]).animate(controller);
  }

  @override
  void initState() {
    super.initState();
    _initScaleController();
  }

  @override
  void didUpdateWidget(covariant _FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _initScaleController();
      _scaleController?.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _scaleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initScaleController();
    final isDark = AppColors.isDark(context);
    final activeColor = AppColors.favorite;
    final inactiveColor =
        isDark ? const Color(0xFF64748B) : AppColors.favoriteInactive;

    Widget starWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _initScaleController();
        _scaleController?.forward(from: 0.0);
        widget.onPressed();
      },
        child: Container(
          height: 26,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isFavorite ? 8 : 6,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: widget.isFavorite
                ? (isDark
                    ? activeColor.withValues(alpha: 0.18)
                    : AppColors.favoriteBg)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isFavorite
                  ? activeColor.withValues(alpha: 0.35)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                widget.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: widget.isFavorite ? activeColor : inactiveColor,
                size: 16,
              ),
              if (widget.isFavorite) ...[
                const SizedBox(width: 4),
                Text(
                  'Favorite',
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

    if (_scaleAnimation != null) {
      return ScaleTransition(
        scale: _scaleAnimation!,
        child: starWidget,
      );
    }

    return starWidget;
  }
}
