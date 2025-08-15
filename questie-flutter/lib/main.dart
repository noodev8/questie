import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QuestieApp(),
    ),
  );
}

class QuestieApp extends ConsumerWidget {
  const QuestieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Questie',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Force light mode always
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
