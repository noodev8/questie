import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';

class RecentAchievements extends ConsumerStatefulWidget {
  const RecentAchievements({super.key});

  @override
  ConsumerState<RecentAchievements> createState() => _RecentAchievementsState();
}

class _RecentAchievementsState extends ConsumerState<RecentAchievements> {
  List<Map<String, dynamic>> _recentBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentBadges();
  }

  Future<void> _loadRecentBadges() async {
    try {
      final result = await UserService.getBadges();
      if (result['success'] && mounted) {
        final allBadges = List<Map<String, dynamic>>.from(result['badges'] ?? []);

        // Filter earned badges and sort by earned_at date
        final earnedBadges = allBadges
            .where((badge) => badge['is_earned'] == true && badge['earned_at'] != null)
            .toList();

        earnedBadges.sort((a, b) {
          try {
            final dateA = DateTime.parse(a['earned_at']);
            final dateB = DateTime.parse(b['earned_at']);
            return dateB.compareTo(dateA); // Most recent first
          } catch (e) {
            return 0;
          }
        });

        setState(() {
          _recentBadges = earnedBadges.take(3).toList(); // Show last 3 earned badges
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
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: const Color(0xFF6B8E6B).withValues(alpha: 0.15),
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

    if (_recentBadges.isEmpty) {
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
          ],
          border: Border.all(
            color: const Color(0xFF6B8E6B).withValues(alpha: 0.15),
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
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No badges earned yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete quests to earn your first badge!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
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
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            ..._recentBadges.map((badge) =>
              _buildAchievementItem(context, badge)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Map<String, dynamic> badge) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E6B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getBadgeIcon(badge['icon']),
              color: const Color(0xFF6B8E6B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${badge['name']} Badge Earned!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),

                Text(
                  badge['description'] ?? 'Achievement unlocked',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          Text(
            _formatDate(badge['earned_at']),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
