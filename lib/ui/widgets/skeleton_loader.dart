import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isDark = AppColors.isDark(context);
        final safeArea = MediaQuery.paddingOf(context);
        final shimmerColor = AppColors.shimmerBaseOf(context).withValues(alpha: _animation.value);

        return Container(
          color: AppColors.scaffoldBackgroundOf(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16 + safeArea.left,
                  12,
                  16 + safeArea.right,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row placeholder (Category badge + favorite icon)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 70,
                          height: 22,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title placeholder
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: 16,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Content placeholder lines
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Footer / timestamp placeholder
                    Container(
                      width: 90,
                      height: 10,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
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
        );
      },
    );
  }
}

class NotesListSkeleton extends StatelessWidget {
  final int count;

  const NotesListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}
