import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../services/user_service.dart';
import '../../../shared/widgets/questie_sticker.dart';

class BadgesSection extends ConsumerStatefulWidget {
  const BadgesSection({super.key});

  @override
  ConsumerState<BadgesSection> createState() => _BadgesSectionState();
}

class _BadgesSectionState extends ConsumerState<BadgesSection> {
  List<Map<String, dynamic>> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final result = await UserService.getBadges();
      if (result['success'] && mounted) {
        setState(() {
          _badges = List<Map<String, dynamic>>.from(result['badges'] ?? []);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          ],
          border: Border.all(
            color: const Color(0xFF6B8E6B).withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6B8E6B),
            ),
          ),
        ),
      );
    }

    // Show a mix of earned and locked badges for preview (up to 6 badges)
    final earnedBadges = _badges.where((badge) => badge['is_earned'] == true).toList();
    final lockedBadges = _badges.where((badge) => badge['is_earned'] != true).toList();

    // Prioritize earned badges, then add some locked ones to fill up to 6 slots
    final previewBadges = <Map<String, dynamic>>[];
    previewBadges.addAll(earnedBadges.take(4)); // Show up to 4 earned

    final remainingSlots = 6 - previewBadges.length;
    if (remainingSlots > 0) {
      previewBadges.addAll(lockedBadges.take(remainingSlots)); // Fill remaining with locked
    }
    
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
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6B8E6B).withValues(alpha: 0.08), // Green shadow
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6B8E6B).withValues(alpha: 0.15), // Green border
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
                  'Stickers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => AppRouter.goToStickers(context),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Changed to 3 badges per row
                crossAxisSpacing: 16, // More spacing for better visual separation
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Taller for better text visibility
              ),
              itemCount: previewBadges.length,
              itemBuilder: (context, index) {
                final badge = previewBadges[index];
                return _buildBadgeItem(context, badge);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, Map<String, dynamic> badge) {
    final isEarned = badge['is_earned'] == true;
    final theme = Theme.of(context);

    return Container(
      // Ensure consistent sizing for all stickers
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8), // Compact padding for profile section
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main sticker with Questie icon
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedQuestieSticker(
                isEarned: isEarned,
                category: badge['category'],
                onTap: () => _showBadgeDetails(context, badge),
                size: 70, // Bigger size for better visibility
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Badge name with Material 3 typography
          Expanded(
            flex: 1,
            child: Text(
              badge['name'] ?? 'Unknown Sticker',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isEarned
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBadgeIcon(String? iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case '🚶':
        return Icons.directions_walk;
      case '🌟':
        return Icons.star;
      case '🗺️':
        return Icons.map;
      case '⚔️':
        return Icons.sports_martial_arts;
      case '🏆':
        return Icons.emoji_events;
      case '👑':
        return Icons.workspace_premium;
      case '💎':
        return Icons.diamond;
      case '💰':
        return Icons.monetization_on;
      case '🎯':
        return Icons.gps_fixed;
      case '⭐':
        return Icons.star_border;
      case '🔥':
        return Icons.local_fire_department;
      case '📅':
        return Icons.calendar_today;
      case '🗓️':
        return Icons.date_range;
      case '🏅':
        return Icons.military_tech;
      case '🎖️':
        return Icons.workspace_premium;
      default:
        return Icons.emoji_events;
    }
  }

  IconData _getBadgeIconByCategory(String? category, String? iconName) {
    // Use different icons based on badge category for better visual distinction
    switch (category?.toLowerCase()) {
      case 'exploration':
      case 'adventure':
        return Icons.explore_rounded;
      case 'fitness':
      case 'health':
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'social':
      case 'community':
      case 'friends':
        return Icons.people_rounded;
      case 'learning':
      case 'education':
      case 'knowledge':
        return Icons.school_rounded;
      case 'creativity':
      case 'art':
      case 'creative':
        return Icons.palette_rounded;
      case 'achievement':
      case 'milestone':
      case 'goal':
        return Icons.emoji_events_rounded;
      case 'daily':
      case 'routine':
      case 'habit':
        return Icons.today_rounded;
      case 'challenge':
      case 'quest':
        return Icons.flag_rounded;
      case 'nature':
      case 'outdoor':
      case 'environment':
        return Icons.nature_rounded;
      case 'mindfulness':
      case 'meditation':
      case 'wellness':
        return Icons.self_improvement_rounded;
      default:
        // Fallback to the original icon mapping if category doesn't match
        return _getBadgeIcon(iconName);
    }
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badge['is_earned'] == true
                    ? const Color(0xFF6B8E6B)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getBadgeIconByCategory(badge['category'], badge['icon']),
                color: badge['is_earned'] == true ? Colors.white : Colors.grey[500],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge['name'] ?? 'Unknown Badge',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge['description'] != null) ...[
              Text(
                badge['description'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],

            // Requirement info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRequirementText(badge),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress info for locked badges
            if (badge['is_earned'] != true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Progress: ${badge['progress_value'] ?? 0} / ${badge['requirement_value'] ?? 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (badge['is_earned'] == true && badge['earned_at'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Earned: ${_formatDate(badge['earned_at'])}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B8E6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getRequirementText(Map<String, dynamic> badge) {
    final type = badge['requirement_type'];
    final value = badge['requirement_value'];

    switch (type) {
      case 'quests_completed':
        return 'Complete $value quests';
      case 'total_points':
        return 'Earn $value total points';
      case 'streak_days':
        return 'Achieve a $value day streak';
      case 'current_streak':
        return 'Maintain a $value day current streak';
      default:
        return 'Unknown requirement';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
