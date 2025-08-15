import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestHistoryScreen extends ConsumerWidget {
  const QuestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quest History',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your adventure journey so far',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter tabs
            _buildFilterTabs(context),
            
            // Quest list
            Expanded(
              child: _buildQuestList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterTab(context, 'All', true),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(context, 'Completed', false),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(context, 'Favorites', false),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isSelected 
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuestList(BuildContext context) {
    final quests = _getMockQuestHistory();
    
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        return _buildQuestHistoryItem(context, quest);
      },
    );
  }

  Widget _buildQuestHistoryItem(BuildContext context, Map<String, dynamic> quest) {
    final isCompleted = quest['completed'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFFDF2E9), // Soft beige
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6B8E6B).withOpacity(0.08), // Green shadow
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6B8E6B).withOpacity(0.15), // Green border
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    quest['icon'] as IconData,
                    color: isCompleted 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted 
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      Text(
                        quest['date'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest['points']} XP',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.schedule,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              quest['description'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            
            if (isCompleted && quest['reflection'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quest['reflection'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockQuestHistory() {
    return [
      {
        'title': 'Visit a local coffee shop',
        'description': 'Discover a new spot in your neighborhood and treat yourself to your favorite drink.',
        'icon': Icons.local_cafe,
        'date': 'Today',
        'completed': true,
        'points': 50,
        'reflection': 'Found an amazing little café with the best latte art! The barista was so friendly.',
      },
      {
        'title': 'Take a 20-minute mindful walk',
        'description': 'Go for a peaceful walk in your neighborhood or a nearby park.',
        'icon': Icons.directions_walk,
        'date': 'Yesterday',
        'completed': true,
        'points': 30,
        'reflection': 'Really helped clear my mind after a busy day. Noticed some beautiful flowers blooming.',
      },
      {
        'title': 'Call an old friend',
        'description': 'Reconnect with someone you haven\'t spoken to in a while.',
        'icon': Icons.phone,
        'date': '2 days ago',
        'completed': true,
        'points': 40,
        'reflection': 'Had such a great conversation with Sarah! We\'re planning to meet up next week.',
      },
      {
        'title': 'Try a new restaurant',
        'description': 'Explore a cuisine you\'ve never tried before.',
        'icon': Icons.restaurant,
        'date': '3 days ago',
        'completed': false,
        'points': 60,
      },
      {
        'title': 'Help a neighbor',
        'description': 'Offer assistance to someone in your community.',
        'icon': Icons.volunteer_activism,
        'date': '4 days ago',
        'completed': true,
        'points': 70,
        'reflection': 'Helped Mrs. Johnson carry her groceries. She invited me for tea next week!',
      },
    ];
  }
}
