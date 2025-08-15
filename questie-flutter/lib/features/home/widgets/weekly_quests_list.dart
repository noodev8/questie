import 'package:flutter/material.dart';

class WeeklyQuestsList extends StatelessWidget {
  const WeeklyQuestsList({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyQuests = [
      {
        'title': 'Practice gratitude daily',
        'description': 'Write down 3 things you\'re grateful for',
        'progress': 3,
        'total': 7,
        'icon': '🙏',
      },
      {
        'title': 'Take mindful walks',
        'description': '15-minute walks in nature',
        'progress': 2,
        'total': 5,
        'icon': '🚶‍♀️',
      },
      {
        'title': 'Digital detox hour',
        'description': 'One hour without screens',
        'progress': 4,
        'total': 7,
        'icon': '📱',
      },
      {
        'title': 'Connect with loved ones',
        'description': 'Call or message someone you care about',
        'progress': 1,
        'total': 3,
        'icon': '💝',
      },
      {
        'title': 'Practice deep breathing',
        'description': '5 minutes of focused breathing',
        'progress': 5,
        'total': 7,
        'icon': '🌬️',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE8F5E8), // Light green
                const Color(0xFFFDF2E9), // Soft beige
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF6B8E6B).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B8E6B).withOpacity(0.2),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isCompleted 
              ? const Color(0xFFE8F5E8) // Light green when completed
              : const Color(0xFFFDF2E9), // Soft beige when in progress
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6B8E6B).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: isCompleted 
            ? const Color(0xFF6B8E6B).withOpacity(0.3)
            : const Color(0xFF6B8E6B).withOpacity(0.1),
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
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8F5E8),
                  const Color(0xFFFDF2E9),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B8E6B).withOpacity(0.2),
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
