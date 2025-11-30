import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/app/routes.dart';
import 'package:nutriguide/core/theme/app_theme.dart';
import 'package:nutriguide/features/auth/feature_auth.dart';
import 'package:nutriguide/features/chat/feature_chat.dart';
import 'package:nutriguide/features/photos/feature_photos.dart';
import 'package:nutriguide/features/profile/feature_profile.dart';

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth provider to detect login/logout state changes
    final authState = ref.watch(authProvider);
    // Watch the initial auth check to show loading during startup
    final checkInitial = ref.watch(checkInitialAuthProvider);

    return MaterialApp(
      title: 'NutriGuide AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildHome(authState, checkInitial),
      onGenerateRoute: Routes.generateRoute,
    );
  }

  Widget _buildHome(
      AsyncValue<User?> authState, AsyncValue<User?> checkInitial) {
    // During initial load, show loading spinner
    if (checkInitial.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // After initial check, use authState to determine what to show
    return authState.when(
      data: (user) {
        if (user != null) {
          return const _MainTabScaffold();
        }
        return const LoginScreen();
      },
      loading: () {
        return const LoginScreen();
      },
      error: (err, stack) {
        return const LoginScreen();
      },
    );
  }
}

// Simple Bottom Nav Scaffold to hold the main tabs
class _MainTabScaffold extends StatefulWidget {
  const _MainTabScaffold();

  @override
  State<_MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<_MainTabScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ChatScreen(),
    const CameraScreen(), // Note: Camera usually opens full screen, but for tab nav:
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // If Camera (index 1) is selected, maybe open full screen instead of tab?
          // For MVP simplicity, we keep it as a tab or push route.
          if (index == 1) {
            Navigator.pushNamed(context, Routes.camera);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
