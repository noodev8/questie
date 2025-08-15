// Dialog Service - Global service for showing dialogs from anywhere in the app
// Useful for showing dialogs when widgets might be unmounted

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogService {
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  // Initialize with the navigator key
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }
  
  // Get the current context
  static BuildContext? get _context => _navigatorKey?.currentContext;
  
  // Show email verification dialog
  static Future<void> showEmailVerificationDialog(String email) async {
    final context = _context;
    if (context == null) {
      print('DialogService: No context available');
      return;
    }
    
    final theme = Theme.of(context);
    
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            Icons.mark_email_unread,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Check Your Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We\'ve sent a verification email to:',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 16),
              Text(
                'Please check your email and click the verification link to activate your account.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navigate to email verification screen
                context.pushReplacement('/email-verification', extra: {
                  'email': email,
                });
              },
              child: const Text('Resend Email'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Go back to login
                context.pop();
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('DialogService: Error showing dialog: $e');
    }
  }
}
