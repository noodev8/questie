// Dialog Service - Global service for showing dialogs from anywhere in the app
// Useful for showing dialogs when widgets might be unmounted

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';

class DialogService {
  // Show email verification dialog using the global navigator key
  static Future<void> showEmailVerificationDialog(String email) async {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      return _showDialogInternal(context, email);
    }
    debugPrint('DialogService: No valid context available from navigator key');
  }

  // Internal method to show the dialog with a valid context
  static Future<void> _showDialogInternal(BuildContext context, String email) async {
    final theme = Theme.of(context);

    try {
      await showDialog(
        context: context,
        barrierDismissible: false, // Modal dialog - blocks background interaction
        builder: (dialogContext) => AlertDialog(
          // Icon with generous spacing
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),

          // Title with proper spacing
          title: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Verification Email Sent',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Content with clear messaging and lots of white space
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'A verification email has been sent to:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Email address in highlighted container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    email,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions with clear messaging
                Text(
                  'Please check your email and click the verification link to activate your account.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You must verify your email before you can log in.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Single action button with proper spacing
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Navigate back to login screen
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Dialog styling with lots of white space
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    } catch (e) {
      debugPrint('DialogService: Error showing dialog: $e');
    }
  }

  // Test method to manually show the dialog (for development/testing)
  static Future<void> showTestEmailVerificationDialog() async {
    await showEmailVerificationDialog('test@example.com');
  }
}
