import 'package:flutter/material.dart';

class WeeklyProgressBarWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? weeklyQuests;
  final bool isLoading;

  const WeeklyProgressBarWidget({
    super.key,
    required this.weeklyQuests,
    required this.isLoading,
  });

  double _calculateProgress() {
    if (weeklyQuests == null || weeklyQuests!.isEmpty) {
      return 0.0;
    }

    int totalQuests = weeklyQuests!.length;
    int completedQuests = weeklyQuests!.where((quest) => quest['is_completed'] == true).length;

    return totalQuests > 0 ? completedQuests / totalQuests : 0.0;
  }

  String _getProgressText() {
    if (weeklyQuests == null || weeklyQuests!.isEmpty) {
      return 'No weekly quests available';
    }

    int totalQuests = weeklyQuests!.length;
    int completedQuests = weeklyQuests!.where((quest) => quest['is_completed'] == true).length;

    return '$completedQuests of $totalQuests weekly challenges completed';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final progress = _calculateProgress();
    final progressText = _getProgressText();
    final progressPercent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6B8E6B).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF6B8E6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF6B8E6B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E6B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E6B),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            progressText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
