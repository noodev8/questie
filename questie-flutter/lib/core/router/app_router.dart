import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/quest/screens/quest_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/history/screens/quest_history_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/badges/screens/badges_screen.dart';
import '../../shared/widgets/main_navigation.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/email_verification_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      // Don't redirect while loading
      if (isLoading) return null;

      final isAuthRoute = state.uri.path.startsWith('/login') ||
                         state.uri.path.startsWith('/register') ||
                         state.uri.path.startsWith('/forgot-password') ||
                         state.uri.path.startsWith('/email-verification') ||
                         state.uri.path.startsWith('/reset-password');

      // If not authenticated and not on auth route, go to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // If authenticated and on auth route (except reset-password), go to home
      if (isAuthenticated && isAuthRoute && !state.uri.path.startsWith('/reset-password')) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),

      // Protected routes with navigation shell
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
          GoRoute(
            path: '/badges',
            name: 'badges',
            builder: (context, state) => const BadgesScreen(),
          ),
        ],
      ),

      // Quest details route (protected)
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

  static void goToBadges(BuildContext context) {
    context.push('/badges');
  }
}
