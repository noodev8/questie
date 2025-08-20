import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/quest_service.dart';
import '../../../services/user_service.dart';
import '../../../shared/widgets/quest_completion_indicator.dart';

class DailyQuestCard extends StatefulWidget {
  final VoidCallback? onQuestCompleted;

  const DailyQuestCard({
    super.key,
    this.onQuestCompleted,
  });

  @override
  State<DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends State<DailyQuestCard> {
  Map<String, dynamic>? _dailyQuest;
  bool _isLoading = true;
  String? _error;
  bool _showStamp = false;
  List<dynamic> _completionBadges = [];

  @override
  void initState() {
    super.initState();
    _loadDailyQuest();
  }

  @override
  void didUpdateWidget(DailyQuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Schedule reload for next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDailyQuest();
      }
    });
  }

  Future<void> _loadDailyQuest() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final quest = await QuestService.getDailyQuest();

      if (mounted) {
        setState(() {
          _dailyQuest = quest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildContent(context),
        // Show floating completion animation when needed
        if (_showStamp)
          Positioned.fill(
            child: Center(
              child: FloatingQuestCompletionAnimation(
                onComplete: _onStampComplete,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard(context);
    }

    if (_error != null || _dailyQuest == null) {
      return _buildErrorCard(context);
    }

    return _buildQuestCard(context, _dailyQuest!);
  }

  Future<void> _showRerollDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reroll Daily Quest'),
        content: const Text(
          'Are you sure you want to reroll your daily quest? You can only do this once per day and will get a different quest.',
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
      await _rerollDailyQuest();
    }
  }

  Future<void> _rerollDailyQuest() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final newQuest = await QuestService.rerollDailyQuest();

      if (newQuest != null) {
        if (mounted) {
          setState(() {
            _dailyQuest = newQuest;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily quest rerolled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reroll quest. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }





  Future<void> _uncompleteQuest(Map<String, dynamic> quest) async {
    try {
      final result = await QuestService.uncompleteQuest(
        quest['assignment_id'],
      );

      if (result != null) {
        // Update quest state locally to avoid full reload and potential scrolling
        if (mounted && _dailyQuest != null) {
          setState(() {
            // Update quest completion status directly on the quest object
            _dailyQuest!['is_completed'] = false;
            _dailyQuest!['completed_at'] = null;
          });
        }

        // Don't call onQuestCompleted to prevent screen jumping
        // The local state is already updated, and stats cache is cleared

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quest unmarked successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to unmark quest. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Future<void> _completeQuestWithAnimation(Map<String, dynamic> quest) async {
    try {
      final result = await QuestService.completeQuest(
        quest['assignment_id'],
        completionNotes: 'Completed from daily quest card',
      );

      if (result != null) {
        // Store the badge info for the stamp completion handler
        _completionBadges = result['newly_earned_badges'] as List<dynamic>? ?? [];

        // Update quest state locally immediately
        if (mounted && _dailyQuest != null) {
          setState(() {
            // Update quest completion status directly on the quest object
            _dailyQuest!['is_completed'] = true;
            _dailyQuest!['completed_at'] = DateTime.now().toIso8601String();
            // Show completion animation
            _showStamp = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete quest. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onStampComplete() {
    // Reset the stamp animation state
    if (mounted) {
      setState(() {
        _showStamp = false;
      });
    }

    // Clear user stats cache to ensure fresh data
    UserService.clearStatsCache();

    // Don't call onQuestCompleted here to prevent screen jumping
    // The local state is already updated, and stats cache is cleared
    // Parent will get updated stats when it naturally refreshes

    // No snackbar messages - just animation and DB update
    // Note: Quest state is already updated in _completeQuestWithAnimation
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
    // Check both possible structures for completion status
    final isCompleted = quest['assignment']?['is_completed'] ?? quest['is_completed'] ?? false;

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
            // Status badge removed as requested
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
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildQuestTag(context, quest['category'] ?? 'Quest'),
                      _buildQuestTag(context, duration),
                      _buildQuestTag(context, '${quest['points'] ?? 0} pts'),
                    ],
                  ),
                ),
                // Checkbox for quick completion
                Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) {
                    if (value == true && !isCompleted) {
                      // Complete directly without confirmation
                      _completeQuestWithAnimation(quest);
                    } else if (value == false && isCompleted) {
                      // Unmark directly without confirmation
                      _uncompleteQuest(quest);
                    }
                  },
                  activeColor: const Color(0xFF6B8E6B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (isCompleted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final questId = quest['quest_id']?.toString();
                    if (questId != null && questId.isNotEmpty) {
                      print('Daily quest (completed) - Navigating to quest details: $questId'); // Debug log
                      final result = await context.push('/quest/$questId');
                      if (result == true && widget.onQuestCompleted != null) {
                        widget.onQuestCompleted!();
                      }
                    } else {
                      print('Daily quest (completed) - Quest ID is null or empty: ${quest['quest_id']}'); // Debug log
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[700],
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final questId = quest['quest_id']?.toString();
                        if (questId != null && questId.isNotEmpty) {
                          print('Daily quest - Navigating to quest details: $questId'); // Debug log
                          final result = await context.push('/quest/$questId');
                          if (result == true && widget.onQuestCompleted != null) {
                            widget.onQuestCompleted!();
                          }
                        } else {
                          print('Daily quest - Quest ID is null or empty: ${quest['quest_id']}'); // Debug log
                        }
                      },
                      child: const Text('Start Quest'),
                    ),
                  ),
                  if (quest['can_reroll'] == true) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRerollDialog(context),
                        child: const Text('Reroll'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }
}
