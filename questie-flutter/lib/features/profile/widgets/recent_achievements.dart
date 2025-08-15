import 'package:flutter/material.dart';

class RecentAchievements extends StatelessWidget {
  const RecentAchievements({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = _getMockAchievements();
    
    return Container(
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ...achievements.map((achievement) => 
              _buildAchievementItem(context, achievement)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Map<String, dynamic> achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: achievement['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                
                Text(
                  achievement['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            achievement['date'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockAchievements() {
    return [
      {
        'title': 'Coffee Explorer Badge Earned!',
        'description': 'Visited 5 different coffee shops',
        'icon': Icons.local_cafe,
        'color': const Color(0xFF8B7355), // Warm brown/beige
        'date': '2 days ago',
      },
      {
        'title': '7-Day Streak!',
        'description': 'Completed quests for 7 days in a row',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFF6B8E6B), // Green
        'date': '1 week ago',
      },
      {
        'title': 'Social Butterfly Badge',
        'description': 'Connected with 10 new people',
        'icon': Icons.people,
        'color': const Color(0xFF6B8E6B), // Green
        'date': '2 weeks ago',
      },
    ];
  }
}
