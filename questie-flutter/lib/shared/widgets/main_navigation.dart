import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;
  
  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    int currentIndex = 0;
    switch (currentLocation) {
      case '/home':
        currentIndex = 0;
        break;
      case '/profile':
        currentIndex = 1;
        break;
      case '/history':
        currentIndex = 2;
        break;
      case '/settings':
        currentIndex = 3;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/profile');
                  break;
                case 2:
                  context.go('/history');
                  break;
                case 3:
                  context.go('/settings');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
