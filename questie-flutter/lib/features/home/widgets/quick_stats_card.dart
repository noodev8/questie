import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';

class QuickStatsCard extends ConsumerStatefulWidget {
  const QuickStatsCard({super.key});

  @override
  ConsumerState<QuickStatsCard> createState() => _QuickStatsCardState();
}

class _QuickStatsCardState extends ConsumerState<QuickStatsCard> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(QuickStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when the widget is updated (e.g., when key changes)
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final result = await UserService.getUserStats();
      if (result['success'] && mounted) {
        setState(() {
          _stats = result['stats'];
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6B8E6B).withValues(alpha: 0.08), // Green shadow
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6B8E6B).withValues(alpha: 0.15), // Green border
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.local_fire_department_outlined,
                          value: '${_stats?['current_streak_days'] ?? 0}',
                          label: 'Day Streak',
                          color: Colors.orange[400]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.emoji_events_outlined,
                          value: '${_stats?['badge_count'] ?? 0}',
                          label: 'Badges',
                          color: Colors.amber[400]!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.check_circle_outline,
                          value: '${_stats?['total_quests_completed'] ?? 0}',
                          label: 'Completed',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
