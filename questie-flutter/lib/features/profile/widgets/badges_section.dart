import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';

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
                  onPressed: () => AppRouter.goToBadges(context),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main badge container (scout badge shape)
          Container(
            decoration: BoxDecoration(
              gradient: isEarned
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8FBC8F), // Light green
                        Color(0xFF6B8E6B), // Main green
                        Color(0xFF556B55), // Darker green
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                        Colors.grey[500]!,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEarned
                    ? const Color(0xFF4A6741)
                    : Colors.grey[600]!,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge icon with circular background
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEarned
                            ? const Color(0xFF4A6741)
                            : Colors.grey[600]!,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      color: isEarned
                          ? const Color(0xFF6B8E6B)
                          : Colors.grey[500],
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Badge name
                  Text(
                    badge['name'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Lock overlay for locked badges
          if (!isEarned) ...[
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
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
