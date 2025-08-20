import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  List<Map<String, dynamic>> _badges = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges({bool forceRefresh = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final result = await UserService.getBadges(forceRefresh: forceRefresh);
      if (mounted) {
        if (result['success']) {
          setState(() {
            _badges = List<Map<String, dynamic>>.from(result['badges'] ?? []);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Failed to load badges';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load badges: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(context)
                      : _buildBadgesGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final earnedCount = _badges.where((badge) => badge['is_earned'] == true).length;
    final totalCount = _badges.length;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32), // More generous padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded), // More rounded Material 3 icon
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.all(12), // More padding
                ),
              ),
              const SizedBox(width: 20), // More spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badges',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5, // Better letter spacing for Material 3
                      ),
                    ),
                    const SizedBox(height: 6), // Slightly more spacing
                    Text(
                      '$earnedCount of $totalCount earned',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32), // More spacing

          // Progress bar with Material 3 styling
          if (totalCount > 0 && earnedCount > 0) ...[
            Container(
              height: 10, // Slightly taller for better visibility
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: earnedCount / totalCount,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12), // More spacing
            Text(
              '${((earnedCount / totalCount) * 100).toInt()}% Complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Badges',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBadges,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    if (_badges.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadBadges(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Badges Available',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete quests to start earning badges!\nPull down to refresh.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBadges(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32), // More generous padding
        child: Column(
          children: [
            // Earned badges section
            if (_badges.any((badge) => badge['is_earned'] == true)) ...[
              _buildSectionHeader(context, 'Earned', Icons.emoji_events_rounded),
              const SizedBox(height: 24), // More spacing
              _buildBadgesSection(context, _badges.where((badge) => badge['is_earned'] == true).toList()),
              const SizedBox(height: 48), // Much more spacing between sections
            ],

            // Locked badges section
            if (_badges.any((badge) => badge['is_earned'] != true)) ...[
              _buildSectionHeader(context, 'Locked', Icons.lock_outline_rounded),
              const SizedBox(height: 24), // More spacing
              _buildBadgesSection(context, _badges.where((badge) => badge['is_earned'] != true).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4), // Slight indent for alignment
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22, // Slightly larger for Material 3
          ),
          const SizedBox(width: 12), // More spacing
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1, // Better letter spacing for Material 3
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context, List<Map<String, dynamic>> badges) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Three badges in a row
        crossAxisSpacing: 20, // More spacing between badges
        mainAxisSpacing: 24, // More vertical spacing
        childAspectRatio: 0.75, // Taller for better text visibility
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(context, badge);
      },
    );
  }

  Widget _buildBadgeCard(BuildContext context, Map<String, dynamic> badge) {
    final isEarned = badge['is_earned'] == true;
    final progress = badge['progress_value'] ?? 0;
    final requirement = badge['requirement_value'] ?? 1;
    final progressPercent = requirement > 0 ? (progress / requirement).clamp(0.0, 1.0) : 0.0;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        // Ensure consistent sizing for all badges
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24), // More rounded for Material 3
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main badge container with cute styling
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: isEarned
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surfaceContainerHighest,
                          theme.colorScheme.surfaceContainer,
                          theme.colorScheme.surfaceContainerHigh,
                        ],
                      ),
                borderRadius: BorderRadius.circular(28), // More rounded for cuteness
                border: Border.all(
                  color: isEarned
                      ? theme.colorScheme.primary.withValues(alpha: 0.4)
                      : theme.colorScheme.outline.withValues(alpha: 0.15),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isEarned
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20), // More generous padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge icon with cute styling and lock overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main badge icon with cute circular design
                        Container(
                          width: 56, // Slightly larger for cuteness
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isEarned
                                ? RadialGradient(
                                    center: Alignment.topLeft,
                                    radius: 1.2,
                                    colors: [
                                      theme.colorScheme.primary.withValues(alpha: 0.9),
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(alpha: 0.8),
                                    ],
                                  )
                                : RadialGradient(
                                    center: Alignment.topLeft,
                                    radius: 1.2,
                                    colors: [
                                      theme.colorScheme.surfaceContainerHigh,
                                      theme.colorScheme.surfaceContainer,
                                      theme.colorScheme.surfaceContainerHighest,
                                    ],
                                  ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isEarned
                                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isEarned
                                    ? theme.colorScheme.primary.withValues(alpha: 0.25)
                                    : theme.colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getBadgeIconByCategory(badge['category'], badge['icon']),
                            color: isEarned
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            size: 28, // Larger icon for cuteness
                          ),
                        ),

                        // Cute lock overlay for locked badges
                        if (!isEarned)
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16), // More spacing

                    // Badge name with Material 3 typography - constrained to prevent overflow
                    Flexible(
                      child: Text(
                        badge['name'] ?? 'Unknown Badge',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEarned
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface, // Darker text for better visibility
                          fontSize: 12, // Slightly larger for better readability
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Progress indicator for locked badges with Material 3 styling
                    if (!isEarned && progressPercent > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressPercent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$progress / $requirement',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Lock overlay for locked badges with Material 3 styling
            if (!isEarned) ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.scrim.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_rounded, // More rounded Material 3 icon
                    color: theme.colorScheme.onError,
                    size: 14, // Slightly smaller for 3-column layout
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getBadgeIcon(String? iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case '🚶':
        return Icons.directions_walk;
      case '☕':
        return Icons.local_cafe;
      case '👥':
        return Icons.people;
      case '📅':
        return Icons.calendar_today;
      case '🌳':
        return Icons.park;
      case '🔥':
        return Icons.local_fire_department;
      case '⭐':
        return Icons.star;
      case '🏆':
        return Icons.emoji_events;
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
