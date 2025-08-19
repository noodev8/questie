import 'package:flutter/material.dart';
import '../../../services/quest_service.dart';

class WeeklyQuestsList extends StatefulWidget {
  const WeeklyQuestsList({super.key});

  @override
  State<WeeklyQuestsList> createState() => _WeeklyQuestsListState();
}

class _WeeklyQuestsListState extends State<WeeklyQuestsList> {
  List<Map<String, dynamic>>? _weeklyQuests;
  bool _canReroll = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyQuests();
  }

  Future<void> _loadWeeklyQuests() async {
    try {
      final questData = await QuestService.getWeeklyQuestsWithRerollInfo();
      if (questData != null) {
        setState(() {
          _weeklyQuests = questData['quests'];
          _canReroll = questData['can_reroll'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showRerollDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reroll Weekly Quests'),
        content: const Text(
          'Are you sure you want to reroll all your weekly quests? You can only do this once per week and will get 5 different quests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reroll'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _rerollWeeklyQuests();
    }
  }

  Future<void> _rerollWeeklyQuests() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final newQuests = await QuestService.rerollWeeklyQuests();

      if (newQuests != null) {
        setState(() {
          _weeklyQuests = newQuests;
          _canReroll = false; // Can't reroll again this week
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weekly quests rerolled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reroll quests. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weeklyQuests == null || _weeklyQuests!.isEmpty) {
      return const Center(
        child: Text('No weekly quests available'),
      );
    }

    final weeklyQuests = _weeklyQuests!.map((quest) => {
      'title': quest['title'] ?? 'Weekly Quest',
      'description': quest['description'] ?? 'Complete this weekly quest',
      'progress': quest['is_completed'] == true ? 1 : 0,
      'total': 1,
      'icon': QuestService.getCategoryIcon(quest['category'] ?? ''),
      'points': quest['points'] ?? 0,
      'category': quest['category'] ?? 'Quest',
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF6B8E6B).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B8E6B).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month,
                color: const Color(0xFF6B8E6B),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Weekly Challenges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6B8E6B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              if (_canReroll) ...[
                TextButton.icon(
                  onPressed: () => _showRerollDialog(context),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Reroll'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B8E6B),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Quest List
        ...weeklyQuests.map((quest) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildQuestItem(context, quest),
        )),
      ],
    );
  }

  Widget _buildQuestItem(BuildContext context, Map<String, dynamic> quest) {
    final progress = quest['progress'] as int;
    final total = quest['total'] as int;
    final progressPercent = progress / total;
    final isCompleted = progress >= total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6B8E6B).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: isCompleted
            ? const Color(0xFF6B8E6B).withValues(alpha: 0.3)
            : const Color(0xFF6B8E6B).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B8E6B).withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                quest['icon'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest['title'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D4A2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B8E6B),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: const Color(0xFFE8F5E8),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF6B8E6B),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$progress/$total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B8E6B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Completion indicator
          if (isCompleted)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6B8E6B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
