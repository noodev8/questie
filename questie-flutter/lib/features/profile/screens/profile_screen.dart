// Profile Screen - User profile management with authentication integration
// Features display name editing, logout functionality, and user information display

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/stats_overview.dart';
import '../widgets/badges_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  bool _isEditingName = false;
  String? _selectedProfileIcon; // Local state for profile icon

  // Available profile icons - Only existing Questie profile pictures
  final List<Map<String, dynamic>> _profileIcons = [
    {'type': 'asset', 'value': 'assets/icons/questie-pic1.png', 'name': 'Questie 1'},
    {'type': 'asset', 'value': 'assets/icons/questie-pic2.png', 'name': 'Questie 2'},
    {'type': 'asset', 'value': 'assets/icons/questie-pic3.png', 'name': 'Questie 3'},
    {'type': 'asset', 'value': 'assets/icons/questie-pic4.png', 'name': 'Questie 4'},
    {'type': 'asset', 'value': 'assets/icons/questie-pic5.png', 'name': 'Questie 5'},
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;

    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showDeleteAccountDialog();
    if (!confirmed) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting account...'),
            ],
          ),
        ),
      );
    }

    try {
      final result = await ref.read(authProvider.notifier).deleteAccount();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (result['success']) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to register screen
          context.go('/register');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDeleteAccountDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('All your data will be permanently deleted from our servers.'),
            SizedBox(height: 16),
            Text(
              'This includes:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• All quest assignments and completions'),
            Text('• Badge progress and earned achievements'),
            Text('• User statistics and streaks'),
            Text('• Daily activity history'),
            Text('• Account settings and profile'),
            SizedBox(height: 16),
            Text(
              'Are you absolutely sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showProfileIconPicker() async {
    final theme = Theme.of(context);
    final authState = ref.read(authProvider);
    final currentIcon = authState.user?['profile_icon'] ?? _profileIcons[0]['value'].toString();

    final selectedIcon = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Your Profile Icon'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Set a fixed height for scrolling
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _profileIcons.length,
            itemBuilder: (context, index) {
              final iconData = _profileIcons[index];
              final iconValue = iconData['value'].toString();
              final isSelected = iconValue == currentIcon;

              return GestureDetector(
                onTap: () => Navigator.of(context).pop(iconData),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                      : theme.colorScheme.surface,
                  ),
                  child: Center(
                    child: iconData['type'] == 'asset'
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            iconData['value'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: theme.colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          iconData['value'],
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedIcon != null) {
      final selectedValue = selectedIcon['value'].toString();
      if (selectedValue != currentIcon) {
        // Update profile icon in backend silently
        await ref.read(authProvider.notifier).updateProfile(
          profileIcon: selectedValue,
        );
      }
    }
  }

  Future<void> _handleUpdateDisplayName() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).updateProfile(
      displayName: _displayNameController.text.trim(),
    );

    if (success) {
      if (mounted) {
        setState(() {
          _isEditingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Display name updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update display name'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startEditingName(String currentName) {
    if (mounted) {
      setState(() {
        _isEditingName = true;
        _displayNameController.text = currentName;
      });
    }
  }

  void _cancelEditingName() {
    if (mounted) {
      setState(() {
        _isEditingName = false;
        _displayNameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final user = authState.user;

    if (!authState.isAuthenticated || user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Not logged in',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Please log in to view your profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header with Account Details
              _buildProfileHeader(context, user, theme),
              const SizedBox(height: 40),

              // Stats Section
              _buildStatsSection(context, theme),
              const SizedBox(height: 40),

              // Badges Section
              _buildBadgesSection(context, theme),
              const SizedBox(height: 40),

              // Action Buttons Section
              _buildActionButtons(context, theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> user, ThemeData theme) {
    final displayName = user['display_name'] ?? 'User';
    final email = user['email'];
    final isAnonymous = user['is_anonymous'] == true;
    final selectedIconValue = user['profile_icon'] ?? _profileIcons[0]['value'].toString();

    // Find the icon data for the selected icon
    final selectedIconData = _profileIcons.firstWhere(
      (icon) => icon['value'].toString() == selectedIconValue,
      orElse: () => _profileIcons[0],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: _showProfileIconPicker,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: selectedIconData['type'] == 'asset'
                  ? Image.asset(
                      selectedIconData['value'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain, // Changed from cover to contain
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 35,
                          color: theme.colorScheme.primary,
                        );
                      },
                    )
                  : Icon(
                      selectedIconData['value'],
                      size: 35,
                      color: theme.colorScheme.primary,
                    ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Name
                if (_isEditingName) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _displayNameController,
                          textCapitalization: TextCapitalization.words,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _handleUpdateDisplayName,
                        icon: const Icon(Icons.check, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton.outlined(
                        onPressed: _cancelEditingName,
                        icon: const Icon(Icons.close, size: 18),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!isAnonymous)
                        IconButton(
                          onPressed: () => _startEditingName(displayName),
                          icon: const Icon(Icons.edit_outlined),
                          iconSize: 18,
                          style: IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 4),

                // Email (if available)
                if (!isAnonymous && email != null)
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                const SizedBox(height: 8),

                // Account Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAnonymous
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAnonymous ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isAnonymous ? 'Guest Account' : 'Registered Account',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isAnonymous ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Your Stats',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const StatsOverview(),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Your Stickers',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const BadgesSection(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Account Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        // Logout Button
        FilledButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Delete Account Button
        OutlinedButton.icon(
          onPressed: _handleDeleteAccount,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Delete Account'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

}
