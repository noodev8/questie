import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'services/dialog_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QuestieApp(),
    ),
  );
}

class QuestieApp extends ConsumerStatefulWidget {
  const QuestieApp({super.key});

  @override
  ConsumerState<QuestieApp> createState() => _QuestieAppState();
}

class _QuestieAppState extends ConsumerState<QuestieApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize dialog service with navigator key
    DialogService.initialize(_navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to trigger router updates
    ref.watch(authProvider);
    final router = ref.watch(routerProvider);

    // Listen for registration success to show popup
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.registrationEmail != null && previous?.registrationEmail == null) {
        // Registration just completed, show popup
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DialogService.showEmailVerificationDialog(next.registrationEmail!);
          // Clear the registration email after showing popup
          ref.read(authProvider.notifier).clearRegistrationEmail();
        });
      }
    });

    return MaterialApp.router(
      title: 'Questie',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Force light mode always
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
