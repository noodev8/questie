import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your Questie experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Experience Section
              _buildSectionHeader(context, 'Experience'),
              const SizedBox(height: 16),
              _buildExperienceSettings(context),
              const SizedBox(height: 32),
              
              // Notifications Section
              _buildSectionHeader(context, 'Notifications'),
              const SizedBox(height: 16),
              _buildNotificationSettings(context),
              const SizedBox(height: 32),
              
              // Privacy Section
              _buildSectionHeader(context, 'Privacy & Data'),
              const SizedBox(height: 16),
              _buildPrivacySettings(context),
              const SizedBox(height: 32),
              
              // About Section
              _buildSectionHeader(context, 'About'),
              const SizedBox(height: 16),
              _buildAboutSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildExperienceSettings(BuildContext context) {
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
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.speed_outlined,
            title: 'Quest Frequency',
            subtitle: 'Daily quests and weekly challenges',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show quest frequency options
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.tune_outlined,
            title: 'Quest Preferences',
            subtitle: 'Customize your quest types',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show quest preferences
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
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
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Daily Quest Reminders',
            subtitle: 'Get notified about new daily quests',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {},
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.schedule_outlined,
            title: 'Reminder Time',
            subtitle: '9:00 AM',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show time picker
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.celebration_outlined,
            title: 'Achievement Notifications',
            subtitle: 'Celebrate your progress',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
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
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            subtitle: 'For local quest recommendations',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {},
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.analytics_outlined,
            title: 'Usage Analytics',
            subtitle: 'Help improve Questie',
            trailing: Switch.adaptive(
              value: false,
              onChanged: (value) {},
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how we protect your data',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
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
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            trailing: const SizedBox.shrink(),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Help us improve Questie',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open feedback form
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.star_outline,
            title: 'Rate Questie',
            subtitle: 'Share your experience',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open app store rating
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with Questie',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open help center
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
