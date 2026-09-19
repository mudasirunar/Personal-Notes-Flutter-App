import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A reusable, animated floating action button for adding notes.
///
/// Encapsulates:
/// - Smooth slide-down & fade-out animation when scrolled.
/// - 90-degree quarter-turn rotation micro-animation on the `+` icon when tapped.
/// - Uniform branding adhering to [AppColors.primary].
class AnimatedFab extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isVisible;
  final String tooltip;

  const AnimatedFab({
    super.key,
    required this.onPressed,
    this.isVisible = true,
    this.tooltip = 'Add Note',
  });

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    await _rotationController.forward(from: 0.0);
    if (!mounted) return;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      offset: widget.isVisible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        opacity: widget.isVisible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: _handlePress,
          tooltip: widget.tooltip,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: RotationTransition(
            turns: _rotationAnimation,
            child: const Icon(
              Icons.add_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
