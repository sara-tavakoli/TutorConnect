import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


/// Animated shimmer placeholder shown while tutor feed loads.
/// Matches the exact height and layout of TutorCard.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xlAll,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            _Box(width: 60, height: 60, radius: AppRadius.lg),
            const SizedBox(width: 14),
            // Text lines placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(width: 140, height: 14, radius: AppRadius.sm),
                  const SizedBox(height: 8),
                  _Box(width: 100, height: 11, radius: AppRadius.sm),
                  const SizedBox(height: 12),
                  _Box(width: 80,  height: 11, radius: AppRadius.sm),
                  const SizedBox(height: 10),
                  Row(children: [
                    _Box(width: 56, height: 22, radius: AppRadius.full),
                    const SizedBox(width: 6),
                    _Box(width: 56, height: 22, radius: AppRadius.full),
                  ]),
                ],
              ),
            ),
            // Rate placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Box(width: 36, height: 14, radius: AppRadius.sm),
                const SizedBox(height: 4),
                _Box(width: 20, height: 11, radius: AppRadius.sm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Box({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
