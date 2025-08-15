import 'package:flutter/material.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = _getMockBadges();
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Badges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all badges
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeItem(context, badge);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, Map<String, dynamic> badge) {
    final isEarned = badge['earned'] as bool;
    
    return Container(
      decoration: BoxDecoration(
        color: isEarned 
            ? (badge['color'] as Color).withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned 
              ? (badge['color'] as Color).withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge['icon'] as IconData,
            size: 24,
            color: isEarned 
                ? badge['color'] as Color
                : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          
          Text(
            badge['name'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isEarned 
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockBadges() {
    return [
      {
        'name': 'First Steps',
        'icon': Icons.directions_walk,
        'color': const Color(0xFF6B8E6B), // Green
        'earned': true,
      },
      {
        'name': 'Coffee Explorer',
        'icon': Icons.local_cafe,
        'color': const Color(0xFF8B7355), // Warm brown/beige
        'earned': true,
      },
      {
        'name': 'Social Butterfly',
        'icon': Icons.people,
        'color': const Color(0xFF6B8E6B), // Green
        'earned': true,
      },
      {
        'name': 'Week Warrior',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF8B7355), // Warm brown/beige
        'earned': true,
      },
      {
        'name': 'Nature Lover',
        'icon': Icons.park,
        'color': const Color(0xFF6B8E6B), // Green
        'earned': false,
      },
      {
        'name': 'Foodie',
        'icon': Icons.restaurant,
        'color': const Color(0xFF8B7355), // Warm brown/beige
        'earned': false,
      },
      {
        'name': 'Photographer',
        'icon': Icons.camera_alt,
        'color': const Color(0xFF6B8E6B), // Green
        'earned': false,
      },
      {
        'name': 'Helper',
        'icon': Icons.volunteer_activism,
        'color': const Color(0xFF8B7355), // Warm brown/beige
        'earned': false,
      },
    ];
  }
}
