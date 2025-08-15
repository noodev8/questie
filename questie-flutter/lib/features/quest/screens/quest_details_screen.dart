import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestDetailsScreen extends ConsumerWidget {
  final String questId;
  
  const QuestDetailsScreen({
    super.key,
    required this.questId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock quest data - in real app this would come from a provider
    final quest = _getMockQuest(questId);
    
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
                  child: Icon(
                    quest['icon'] as IconData,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
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
                      quest['type'] as String,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quest title
                  Text(
                    quest['title'] as String,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quest description
                  Text(
                    quest['description'] as String,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Quest details
                  _buildQuestDetails(context, quest),
                  const SizedBox(height: 32),
                  
                  // Tips section
                  _buildTipsSection(context, quest['tips'] as List<String>),
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
                    quest['duration'] as String,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.star_outline,
                    'Reward',
                    '${quest['points']} points',
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
                    quest['location'] as String,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.people_outline,
                    'Category',
                    quest['category'] as String,
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

  Widget _buildTipsSection(BuildContext context, List<String> tips) {
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Show completion dialog
              _showCompletionDialog(context);
            },
            child: const Text('Complete Quest'),
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quest Completed! 🎉'),
        content: const Text('Great job! You\'ve earned 50 points and unlocked a new badge.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMockQuest(String questId) {
    // Mock data - in real app this would come from a data source
    if (questId == 'daily-1') {
      return {
        'title': 'Visit a local coffee shop you\'ve never been to',
        'description': 'Discover a new spot in your neighborhood and treat yourself to your favorite drink. Take a moment to appreciate the atmosphere and maybe strike up a conversation with the barista or a fellow customer.',
        'type': 'Daily Quest',
        'icon': Icons.local_cafe_outlined,
        'duration': '30 minutes',
        'points': 50,
        'location': 'Local area',
        'category': 'Discovery',
        'tips': [
          'Use Google Maps to find coffee shops within walking distance',
          'Try ordering something different from your usual',
          'Take a photo to remember the experience',
          'Leave a positive review if you enjoyed it',
        ],
      };
    } else {
      return {
        'title': 'Connect with 3 neighbors this week',
        'description': 'Build community connections by having meaningful interactions with people in your neighborhood. This could be helping with groceries, sharing a smile, or having a genuine conversation.',
        'type': 'Weekly Challenge',
        'icon': Icons.people_outline,
        'duration': '7 days',
        'points': 150,
        'location': 'Your neighborhood',
        'category': 'Social',
        'tips': [
          'Start with a simple greeting or smile',
          'Offer help when you see someone struggling',
          'Attend local community events',
          'Walk your dog or spend time in common areas',
        ],
      };
    }
  }
}
