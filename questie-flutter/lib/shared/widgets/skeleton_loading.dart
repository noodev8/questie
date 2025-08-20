import 'package:flutter/material.dart';

/// Skeleton loading widget for better perceived performance
class SkeletonLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for quest cards
class QuestCardSkeleton extends StatelessWidget {
  const QuestCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonLoading(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoading(
                        width: double.infinity,
                        height: 16,
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoading(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SkeletonLoading(
              width: double.infinity,
              height: 14,
            ),
            const SizedBox(height: 8),
            const SkeletonLoading(
              width: double.infinity,
              height: 14,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonLoading(
                  width: 80,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                const SkeletonLoading(
                  width: 60,
                  height: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for stats cards
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SkeletonLoading(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoading(
                    width: 32,
                    height: 20,
                  ),
                  const SizedBox(height: 4),
                  const SkeletonLoading(
                    width: 60,
                    height: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const SkeletonLoading(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoading(
                    width: 32,
                    height: 20,
                  ),
                  const SizedBox(height: 4),
                  const SkeletonLoading(
                    width: 60,
                    height: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const SkeletonLoading(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoading(
                    width: 32,
                    height: 20,
                  ),
                  const SizedBox(height: 4),
                  const SkeletonLoading(
                    width: 60,
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for weekly quest list
class WeeklyQuestsSkeleton extends StatelessWidget {
  const WeeklyQuestsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const SkeletonLoading(
                  width: 20,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoading(
                        width: double.infinity,
                        height: 16,
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoading(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const SkeletonLoading(
                  width: 50,
                  height: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
