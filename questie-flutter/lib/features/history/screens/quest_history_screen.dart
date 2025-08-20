import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/quest_service.dart';

class QuestHistoryScreen extends ConsumerStatefulWidget {
  const QuestHistoryScreen({super.key});

  @override
  ConsumerState<QuestHistoryScreen> createState() => _QuestHistoryScreenState();
}

class _QuestHistoryScreenState extends ConsumerState<QuestHistoryScreen> {
  String _selectedFilter = 'all';
  List<Map<String, dynamic>>? _questHistory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestHistory();
  }

  Future<void> _loadQuestHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final history = await QuestService.getQuestHistory(
        filter: _selectedFilter,
        limit: 50,
      );

      print('Quest history loaded: ${history?.length ?? 0} items'); // Debug
      if (history != null && history.isNotEmpty) {
        print('First item: ${history.first}'); // Debug
      }

      if (mounted) {
        setState(() {
          _questHistory = history ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onFilterChanged(String filter) async {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
      await _loadQuestHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _buildFilterTab(context, 'All', 'all'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(context, 'Completed', 'completed'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab(context, 'Favorites', 'favorites'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, String label, String filterValue) {
    final isSelected = _selectedFilter == filterValue;

    return GestureDetector(
      onTap: () => _onFilterChanged(filterValue),
      child: Container(
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
      ),
    );
  }

  Widget _buildQuestList(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
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
              'Failed to load quest history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questHistory == null || _questHistory!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No quest history yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete some quests to see them here!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _questHistory!.length,
      itemBuilder: (context, index) {
        final quest = _questHistory![index];
        return _buildQuestHistoryItem(context, quest);
      },
    );
  }

  Widget _buildQuestHistoryItem(BuildContext context, Map<String, dynamic> quest) {
    final isCompleted = quest['is_completed'] == true;
    final title = quest['title'] ?? 'Unknown Quest';
    final description = quest['description'] ?? '';
    final categoryName = quest['category_name'] ?? 'General';
    final points = quest['points'] ?? 0;
    final completionNotes = quest['completion_notes'];

    // Format date
    String dateText = 'Unknown date';
    if (quest['completed_at'] != null) {
      final completedAt = DateTime.parse(quest['completed_at']);
      final now = DateTime.now();
      final difference = now.difference(completedAt).inDays;

      if (difference == 0) {
        dateText = 'Today';
      } else if (difference == 1) {
        dateText = 'Yesterday';
      } else if (difference < 7) {
        dateText = '$difference days ago';
      } else {
        dateText = '${completedAt.day}/${completedAt.month}/${completedAt.year}';
      }
    } else if (quest['assigned_date'] != null) {
      final assignedAt = DateTime.parse(quest['assigned_date']);
      final now = DateTime.now();
      final difference = now.difference(assignedAt).inDays;

      if (difference == 0) {
        dateText = 'Today';
      } else if (difference == 1) {
        dateText = 'Yesterday';
      } else if (difference < 7) {
        dateText = '$difference days ago';
      } else {
        dateText = '${assignedAt.day}/${assignedAt.month}/${assignedAt.year}';
      }
    }

    // Get category icon
    IconData categoryIcon = _getCategoryIcon(categoryName);
    
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
                    categoryIcon,
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
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        dateText,
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
                          '+$points XP',
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
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            if (isCompleted && completionNotes != null && completionNotes.isNotEmpty) ...[
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
                        completionNotes,
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

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cafe':
      case 'coffee':
        return Icons.local_cafe;
      case 'exercise':
      case 'fitness':
      case 'walk':
        return Icons.directions_walk;
      case 'social':
      case 'friends':
        return Icons.people;
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'community':
      case 'volunteer':
        return Icons.volunteer_activism;
      case 'nature':
      case 'outdoor':
        return Icons.nature;
      case 'creative':
      case 'art':
        return Icons.palette;
      case 'learning':
      case 'education':
        return Icons.school;
      case 'mindfulness':
      case 'meditation':
        return Icons.self_improvement;
      case 'adventure':
      case 'exploration':
        return Icons.explore;
      default:
        return Icons.star;
    }
  }
}
