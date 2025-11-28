import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/app/routes.dart';
import 'package:nutriguide/core/theme/app_theme.dart';
import 'package:nutriguide/features/auth/feature_auth.dart';
import 'package:nutriguide/features/chat/feature_chat.dart';
import 'package:nutriguide/features/photos/feature_photos.dart';
import 'package:nutriguide/features/profile/feature_profile.dart';
import 'package:nutriguide/core/services/auth_service.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/core/services/logging_service.dart';

// Create a FutureProvider to check initial auth state
final initialAuthProvider = FutureProvider<bool>((ref) async {
  final authService = AuthService(
    apiService: ApiService(
      secureStorage: SecureStorageService(),
      logger: LoggingService.instance,
    ),
    secureStorage: SecureStorageService(),
  );
  return authService.isLoggedIn();
});

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(initialAuthProvider);

    return MaterialApp(
      title: 'NutriGuide AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Applied Vitality Green theme

      // Handle Initial Route based on Auth Check
      home: authState.when(
        data: (isLoggedIn) {
          // If logged in, go to Home (Chat), else Login
          // Note: In a real app with deep linking, we'd use onGenerateInitialRoutes
          return isLoggedIn ? const _MainTabScaffold() : const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) =>
            const LoginScreen(), // Fallback to login on error
      ),

      onGenerateRoute: Routes.generateRoute,
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
