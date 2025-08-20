import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/widgets/weekly_quests_section.dart';

class WeeklyQuestsScreen extends ConsumerStatefulWidget {
  const WeeklyQuestsScreen({super.key});

  @override
  ConsumerState<WeeklyQuestsScreen> createState() => _WeeklyQuestsScreenState();
}

class _WeeklyQuestsScreenState extends ConsumerState<WeeklyQuestsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onQuestCompleted() {
    // Refresh the weekly quests section
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
              // Header Section
              _buildHeaderSection(context),
              const SizedBox(height: 32),

              // Weekly Quests Section
              WeeklyQuestsSection(
                key: ValueKey('weekly_quests_$_refreshCounter'),
                onQuestCompleted: _onQuestCompleted,
              ),
              const SizedBox(height: 32),

              // Tips Section
              _buildTipsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8FDF8), // Very light green tint
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6B8E6B).withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weekly quest icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E6B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month,
              size: 32,
              color: Color(0xFF6B8E6B),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header text
          Text(
            'Weekly Challenges',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D4A2D),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          Text(
            'Take on bigger adventures with weekly quests. Complete all five to unlock special rewards and boost your progress.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2E9), // Soft peach background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6B8E6B).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Weekly Quest Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D4A2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTipItem(
            context,
            '🎯',
            'Plan Ahead',
            'Review your weekly quests at the start of each week to plan your schedule.',
          ),
          const SizedBox(height: 12),
          
          _buildTipItem(
            context,
            '⚡',
            'Stay Consistent',
            'Complete at least one quest per day to maintain momentum throughout the week.',
          ),
          const SizedBox(height: 12),
          
          _buildTipItem(
            context,
            '🏆',
            'Bonus Rewards',
            'Complete all weekly quests to unlock special badges and bonus points.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D4A2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
