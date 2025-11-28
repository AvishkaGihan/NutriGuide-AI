import 'package:flutter/material.dart';
import 'package:nutriguide/features/auth/feature_auth.dart';
import 'package:nutriguide/features/chat/feature_chat.dart';
import 'package:nutriguide/features/photos/feature_photos.dart';
import 'package:nutriguide/features/profile/feature_profile.dart';
import 'package:nutriguide/features/recipes/feature_recipes.dart';

class Routes {
  // Private constructor
  Routes._();

  // Route Constants
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String camera = '/camera';
  static const String chat = '/chat';
  static const String recipeDetail = '/recipe-detail';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- Auth Routes ---
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      // Onboarding requires arguments passed from Register
      // We handle this inside RegisterScreen logic usually, but here is standard route
      case onboarding:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            email: args?['email'] ?? '',
            password: args?['password'] ?? '',
          ),
        );

      // --- Main Features ---
      case home:
        // For MVP, Home is the Chat Screen (as per UX)
        // Or we could build a specific Home Tab View later.
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      case camera:
        return MaterialPageRoute(builder: (_) => const CameraScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case recipeDetail:
        if (settings.arguments is Recipe) {
          return MaterialPageRoute(
            builder: (_) =>
                RecipeDetailScreen(recipe: settings.arguments as Recipe),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
