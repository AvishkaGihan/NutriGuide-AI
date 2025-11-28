import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  // Private constructor to prevent instantiation
  Endpoints._();

  // Load Base URL from .env, default to localhost for Android emulator if missing
  // Note: 10.0.2.2 is the special IP for Android Emulator to reach host localhost
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api/v1';

  // --- Authentication ---
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // --- Chat ---
  static const String chatHistory = '/chat/history';
  static const String chatStream = '/chat/messages/stream';

  // --- Photos ---
  static const String analyzePhoto = '/photos/analyze';

  // --- Recipes ---
  static const String recipes = '/recipes';
  static String recipeDetail(String id) => '/recipes/$id';
  static String recipeVariation(String id) => '/recipes/$id/variation';

  // --- User Profile ---
  static const String profile = '/user/profile';
  static const String deleteAccount = '/user/account';
  static const String exportData = '/user/export-data';
}
