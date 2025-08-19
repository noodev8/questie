import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../services/quest_service.dart';

class WeeklyQuestsSection extends StatefulWidget {
  const WeeklyQuestsSection({super.key});

  @override
  State<WeeklyQuestsSection> createState() => _WeeklyQuestsSectionState();
}

class _WeeklyQuestsSectionState extends State<WeeklyQuestsSection> {
  List<Map<String, dynamic>>? _weeklyQuests;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeeklyQuests();
  }

  Future<void> _loadWeeklyQuests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final quests = await QuestService.getWeeklyQuests();

      setState(() {
        _weeklyQuests = quests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard(context);
    }

    if (_error != null || _weeklyQuests == null || _weeklyQuests!.isEmpty) {
      return _buildErrorCard(context);
    }

    return _buildQuestsCard(context, _weeklyQuests!);
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load weekly quests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWeeklyQuests,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsCard(BuildContext context, List<Map<String, dynamic>> quests) {
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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6B8E6B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE8F5E8), // Light green
                        const Color(0xFFFDF2E9), // Soft beige
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B8E6B).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    '🌟',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Text(
              'Complete 5 challenges this week',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              'Mix of social, wellness, and discovery activities to enrich your week.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            
            // Progress indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: 2 of 5 completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '40%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.4,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Weekly quests list
            ...quests.asMap().entries.map((entry) {
              final index = entry.key;
              final quest = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < quests.length - 1 ? 16 : 0),
                child: _buildWeeklyQuestItem(context, quest),
              );
            }),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to weekly quests details
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('View All Weekly Challenges'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyQuestItem(BuildContext context, Map<String, dynamic> quest) {
    final isCompleted = quest['is_completed'] ?? false;
    final categoryIcon = QuestService.getCategoryIcon(quest['category'] ?? '');
    final duration = QuestService.formatDuration(quest['estimated_duration_minutes']);
    
    return InkWell(
      onTap: () => AppRouter.goToQuestDetails(context, quest['quest_id']?.toString() ?? ''),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.green[50]
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? Colors.green[200]!
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? LinearGradient(
                        colors: [Colors.green[100]!, Colors.green[50]!],
                      )
                    : LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green[300]!
                      : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? Colors.green[200]!.withOpacity(0.4)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 22,
                    )
                  : Text(
                      categoryIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest['title'] ?? 'Weekly Quest',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey[600] : null,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      _buildQuestTag(context, quest['category'] ?? 'Quest'),
                      const SizedBox(width: 8),
                      _buildQuestTag(context, '${quest['points'] ?? 0} pts'),
                      const SizedBox(width: 8),
                      _buildQuestTag(context, duration),
                    ],
                  ),
                ],
              ),
            ),
            
            if (isCompleted) ...[
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
            ] else ...[
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }


}
