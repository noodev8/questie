import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../widgets/daily_quest_card.dart';
import '../widgets/weekly_quests_section.dart';
import '../widgets/quick_stats_card.dart';
import '../../../services/user_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _refreshCounter = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Don't auto-refresh on init to avoid scroll issues
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onQuestCompleted() {
    // Clear user stats cache to force refresh
    UserService.clearStatsCache();

    // Trigger a rebuild to refresh quest data
    setState(() {
      _refreshCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8), // Reduced from 16 to 8

              // Progress Stats
              QuickStatsCard(
                key: ValueKey('quick_stats_$_refreshCounter'),
              ),
              const SizedBox(height: 24),

              // Daily Quest Section
              _buildDailyQuestSection(context),
              const SizedBox(height: 32),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF6B8E6B).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Weekly Quests (5 tasks)
              WeeklyQuestsSection(
                key: ValueKey('weekly_quests_$_refreshCounter'),
                onQuestCompleted: _onQuestCompleted,
              ),
              const SizedBox(height: 32),
              
              // Quick Actions
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const SizedBox.shrink(); // Remove the header content
  }

  Widget _buildDailyQuestSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Quest Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF6B8E6B).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.today_outlined,
                color: Color(0xFF6B8E6B),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Challenge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6B8E6B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Daily Quest Card
        DailyQuestCard(
          key: ValueKey('daily_quest_$_refreshCounter'),
          onQuestCompleted: _onQuestCompleted,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.history,
                label: 'View History',
                onTap: () => AppRouter.goToHistory(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.person,
                label: 'Profile',
                onTap: () => AppRouter.goToProfile(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
