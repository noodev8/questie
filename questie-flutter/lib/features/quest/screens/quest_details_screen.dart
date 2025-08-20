import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/quest_service.dart';
import '../../../shared/widgets/quest_stamp_animation.dart';

class QuestDetailsScreen extends ConsumerStatefulWidget {
  final String questId;

  const QuestDetailsScreen({
    super.key,
    required this.questId,
  });

  @override
  ConsumerState<QuestDetailsScreen> createState() => _QuestDetailsScreenState();
}

class _QuestDetailsScreenState extends ConsumerState<QuestDetailsScreen> {
  Map<String, dynamic>? _quest;
  bool _isLoading = true;
  String? _error;
  bool _showStamp = false;
  List<dynamic> _completionBadges = [];
  bool _isProcessing = false; // Prevent rapid clicking

  @override
  void initState() {
    super.initState();
    _loadQuestDetails();
  }

  Future<void> _loadQuestDetails() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      print('Loading quest details for quest ID: ${widget.questId}'); // Debug log
      final quest = await QuestService.getQuestDetails(widget.questId);
      print('Quest details received: $quest'); // Debug log

      if (mounted) {
        setState(() {
          _quest = quest;
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

  Future<void> _completeQuest() async {
    if (_quest == null || _isProcessing) return;

    final assignment = _quest!['assignment'];
    if (assignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This quest is not currently assigned to you.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (assignment['is_completed'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This quest is already completed.'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final result = await QuestService.completeQuest(
        assignment['assignment_id'],
        completionNotes: 'Completed via quest details screen',
      );

      if (result != null) {
        if (mounted) {
          // Update quest state directly without reloading
          if (_quest != null && _quest!['assignment'] != null) {
            _quest!['assignment']['is_completed'] = true;
            _quest!['assignment']['completed_at'] = DateTime.now().toIso8601String();
          }

          // Store the badge info for the stamp completion handler
          _completionBadges = result['newly_earned_badges'] as List<dynamic>? ?? [];

          // Show stamp animation
          setState(() {
            _showStamp = true;
            _isProcessing = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
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
        setState(() {
          _isProcessing = false;
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

  void _onStampComplete() {
    // Show completion message and navigate back
    if (_completionBadges.isNotEmpty) {
      final badgeNames = _completionBadges.map((badge) => badge['name']).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quest completed! 🏆 New badges earned: $badgeNames'),
          backgroundColor: Colors.amber[700],
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quest completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return QuestStampOverlay(
      showStamp: _showStamp,
      onStampComplete: _onStampComplete,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quest Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _quest == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quest Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load quest details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final quest = _quest!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    QuestService.getCategoryIcon(quest['category'] ?? ''),
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quest type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${quest['difficulty']?.toString().toUpperCase() ?? 'QUEST'} QUEST',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quest title
                  Text(
                    quest['title'] ?? 'Quest Title',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quest description
                  Text(
                    quest['description'] ?? 'Complete this quest to earn points and build your streak.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Quest details
                  _buildQuestDetails(context, quest),
                  const SizedBox(height: 32),
                  
                  // Tips section (generic tips for now)
                  _buildTipsSection(context, quest),
                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(context, quest),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestDetails(BuildContext context, Map<String, dynamic> quest) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quest Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.schedule_outlined,
                    'Duration',
                    QuestService.formatDuration(quest['estimated_duration_minutes']),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.star_outline,
                    'Reward',
                    '${quest['points'] ?? 0} points',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.location_on_outlined,
                    'Location',
                    'Anywhere', // Generic location since we don't have specific location data
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.people_outline,
                    'Category',
                    quest['category']?.toString() ?? 'Quest',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context, Map<String, dynamic> quest) {
    // Generate generic tips based on quest category
    final category = quest['category']?.toString().toLowerCase() ?? '';
    List<String> tips = [];

    switch (category) {
      case 'cafe':
        tips = [
          'Use Google Maps to find nearby coffee shops',
          'Try ordering something different from your usual',
          'Take a photo to remember the experience',
          'Leave a positive review if you enjoyed it',
        ];
        break;
      case 'exercise':
        tips = [
          'Start with a warm-up to prevent injury',
          'Stay hydrated throughout your activity',
          'Listen to your body and rest when needed',
          'Track your progress to stay motivated',
        ];
        break;
      case 'kindness':
        tips = [
          'Small acts of kindness can make a big difference',
          'Be genuine and authentic in your approach',
          'Don\'t expect anything in return',
          'Share your positive experience with others',
        ];
        break;
      case 'culture':
        tips = [
          'Keep an open mind and be curious',
          'Take notes or photos to remember the experience',
          'Ask questions if guided tours are available',
          'Share what you learned with friends or family',
        ];
        break;
      case 'nature':
        tips = [
          'Dress appropriately for the weather',
          'Bring water and snacks if needed',
          'Respect the environment and wildlife',
          'Take time to appreciate the natural beauty',
        ];
        break;
      case 'learning':
        tips = [
          'Set aside dedicated time without distractions',
          'Take notes to help retain information',
          'Practice what you learn to reinforce it',
          'Share your new knowledge with others',
        ];
        break;
      default:
        tips = [
          'Take your time and enjoy the experience',
          'Stay safe and be aware of your surroundings',
          'Document your progress with photos or notes',
          'Celebrate your accomplishment when complete',
        ];
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tips for Success',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> quest) {
    final assignment = quest['assignment'];
    final isAssigned = assignment != null;
    final isCompleted = assignment?['is_completed'] == true;

    return Column(
      children: [
        if (isAssigned) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : (isCompleted
                      ? () => _showUnmarkDialog(context)
                      : () => _showCompletionDialog(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? Colors.orange[700]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ] else ...[
                    Icon(
                      isCompleted ? Icons.undo : Icons.check_circle,
                      size: 20,
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(_isProcessing
                      ? 'Processing...'
                      : (isCompleted ? 'Unmark as Completed' : 'Mark as Completed')),
                ],
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(height: 8),
                Text(
                  'Quest Not Assigned',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This quest is not currently assigned to you. Check your daily or weekly quests.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Quest'),
        content: const Text('Are you sure you want to mark this quest as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _completeQuest();
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showUnmarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unmark Quest'),
        content: const Text('Are you sure you want to unmark this quest as completed? This will deduct the points you earned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _uncompleteQuest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
            ),
            child: const Text('Unmark'),
          ),
        ],
      ),
    );
  }

  Future<void> _uncompleteQuest() async {
    if (_quest == null || _isProcessing) return;

    final assignment = _quest!['assignment'];
    if (assignment == null) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final result = await QuestService.uncompleteQuest(
        assignment['assignment_id'],
      );

      if (result != null) {
        if (mounted) {
          // Reload quest details to update UI state
          await _loadQuestDetails();

          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quest unmarked successfully!'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
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
        setState(() {
          _isProcessing = false;
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


}
