import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/quest/screens/quest_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/history/screens/quest_history_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/main_navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const QuestHistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/quest/:questId',
        name: 'quest-details',
        builder: (context, state) {
          final questId = state.pathParameters['questId']!;
          return QuestDetailsScreen(questId: questId);
        },
      ),
    ],
  );
});

// Navigation helper
class AppRouter {
  static void goToHome(BuildContext context) {
    context.go('/home');
  }
  
  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }
  
  static void goToHistory(BuildContext context) {
    context.go('/history');
  }
  
  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }
  
  static void goToQuestDetails(BuildContext context, String questId) {
    context.push('/quest/$questId');
  }
}
