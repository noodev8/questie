import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../services/quest_service.dart';

class DailyQuestCard extends StatefulWidget {
  const DailyQuestCard({super.key});

  @override
  State<DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends State<DailyQuestCard> {
  Map<String, dynamic>? _dailyQuest;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDailyQuest();
  }

  Future<void> _loadDailyQuest() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final quest = await QuestService.getDailyQuest();

      setState(() {
        _dailyQuest = quest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard(context);
    }

    if (_error != null || _dailyQuest == null) {
      return _buildErrorCard(context);
    }

    return _buildQuestCard(context, _dailyQuest!);
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load daily quest',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyQuest,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, Map<String, dynamic> quest) {
    final categoryIcon = QuestService.getCategoryIcon(quest['category'] ?? '');
    final duration = QuestService.formatDuration(quest['estimated_duration_minutes']);
    final isCompleted = quest['is_completed'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [const Color(0xFFE8F5E8), const Color(0xFFE8F5E8)]
                          : [
                              const Color(0xFFE8F5E8), // Light green
                              const Color(0xFFFDF2E9), // Soft peach/beige
                            ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.3)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoryIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCompleted ? 'Completed' : 'Today\'s Quest',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isCompleted
                              ? Colors.green[700]
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              quest['title'] ?? 'Daily Quest',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              quest['description'] ?? 'Complete your daily quest to earn points and build your streak.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildQuestTag(context, Icons.category_outlined, quest['category'] ?? 'Quest'),
                const SizedBox(width: 12),
                _buildQuestTag(context, Icons.schedule_outlined, duration),
                const SizedBox(width: 12),
                _buildQuestTag(context, Icons.star_outline, '${quest['points'] ?? 0} pts'),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted
                    ? null
                    : () => AppRouter.goToQuestDetails(context, quest['quest_id']?.toString() ?? ''),
                child: Text(isCompleted ? 'Completed' : 'Start Quest'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTag(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
