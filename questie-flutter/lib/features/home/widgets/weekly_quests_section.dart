import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/quest_service.dart';
import '../../../services/user_service.dart';
import 'progress_bar_widget.dart';
import '../../../shared/widgets/quest_completion_indicator.dart';
import '../../../shared/widgets/skeleton_loading.dart';

class WeeklyQuestsSection extends StatefulWidget {
  final VoidCallback? onQuestCompleted;

  const WeeklyQuestsSection({
    super.key,
    this.onQuestCompleted,
  });

  @override
  State<WeeklyQuestsSection> createState() => _WeeklyQuestsSectionState();
}

class _WeeklyQuestsSectionState extends State<WeeklyQuestsSection> {
  List<Map<String, dynamic>>? _weeklyQuests;
  bool _isLoading = true;
  String? _error;
  bool _showStamp = false;
  List<dynamic> _completionBadges = [];

  @override
  void initState() {
    super.initState();
    _loadWeeklyQuests();
  }

  @override
  void didUpdateWidget(WeeklyQuestsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Schedule reload for next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadWeeklyQuests();
      }
    });
  }

  Future<void> _loadWeeklyQuests() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final questData = await QuestService.getWeeklyQuestsWithRerollInfo();

      if (questData != null) {
        if (mounted) {
          setState(() {
            _weeklyQuests = questData['quests'];
            _isLoading = false;
          });
          // Debug: Print the quest data to see can_reroll status
          print('Weekly quests loaded: ${questData['quests']?.length} quests');
          print('Can reroll: ${questData['can_reroll']}');
          if (questData['quests'] != null && questData['quests'].isNotEmpty) {
            print('First quest can_reroll: ${questData['quests'][0]['can_reroll']}');
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _weeklyQuests = null;
            _isLoading = false;
          });
        }
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

    if (_error != null || _weeklyQuests == null || _weeklyQuests!.isEmpty) {
      return _buildErrorCard(context);
    }

    return _buildQuestsCard(context, _weeklyQuests!);
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
        // Reload the quests to get updated can_reroll status
        await _loadWeeklyQuests();

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
        if (mounted && _weeklyQuests != null) {
          setState(() {
            final questIndex = _weeklyQuests!.indexWhere(
              (q) => q['assignment_id'] == quest['assignment_id']
            );
            if (questIndex != -1) {
              // Update quest completion status directly on the quest object
              _weeklyQuests![questIndex]['is_completed'] = false;
              _weeklyQuests![questIndex]['completed_at'] = null;
            }
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
        completionNotes: 'Completed from weekly quests section',
      );

      if (result != null) {
        // Store the badge info for the stamp completion handler
        _completionBadges = result['newly_earned_badges'] as List<dynamic>? ?? [];

        // Update quest state locally immediately
        if (mounted && _weeklyQuests != null) {
          setState(() {
            final questIndex = _weeklyQuests!.indexWhere(
              (q) => q['assignment_id'] == quest['assignment_id']
            );
            if (questIndex != -1) {
              // Update quest completion status directly on the quest object
              _weeklyQuests![questIndex]['is_completed'] = true;
              _weeklyQuests![questIndex]['completed_at'] = DateTime.now().toIso8601String();
            }
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
    return const WeeklyQuestsSkeleton();
  }

  Widget _buildErrorCard(BuildContext context) {
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
              'Unable to load weekly quests',
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
              onPressed: _loadWeeklyQuests,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsCard(BuildContext context, List<Map<String, dynamic>> quests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              if (quests.any((q) => q['can_reroll'] == true)) ...[
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
        const SizedBox(height: 16),

        // Weekly Progress Bar
        WeeklyProgressBarWidget(
          weeklyQuests: quests,
          isLoading: false,
        ),

        // Quest List
        ...quests.map((quest) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildWeeklyQuestItem(context, quest),
        )),
      ],
    );
  }

  Widget _buildWeeklyQuestItem(BuildContext context, Map<String, dynamic> quest) {
    // Check both possible structures for completion status
    final isCompleted = quest['assignment']?['is_completed'] ?? quest['is_completed'] ?? false;
    final categoryIcon = QuestService.getCategoryIcon(quest['category'] ?? '');
    final duration = QuestService.formatDuration(quest['estimated_duration_minutes']);

    return GestureDetector(
      onTap: () async {
        final questId = quest['quest_id']?.toString();
        if (questId != null && questId.isNotEmpty) {
          print('Navigating to quest details: $questId'); // Debug log
          final result = await context.push('/quest/$questId');
          if (result == true && widget.onQuestCompleted != null) {
            widget.onQuestCompleted!();
          }
        } else {
          print('Quest ID is null or empty: ${quest['quest_id']}'); // Debug log
        }
      },
        child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green[50]!
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.3)
                      : const Color(0xFF6B8E6B).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 22,
                      )
                    : Text(
                        categoryIcon,
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest['title'] ?? 'Weekly Quest',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey[600] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildQuestTag(context, quest['category'] ?? 'Quest'),
                            _buildQuestTag(context, '${quest['points'] ?? 0} pts'),
                            _buildQuestTag(context, duration),
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
                ],
              ),
            ),

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
