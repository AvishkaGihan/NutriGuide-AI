import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';

class AuthService {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthService({
    required ApiService apiService,
    required SecureStorageService secureStorage,
  })  : _apiService = apiService,
        _secureStorage = secureStorage;

  // --- Login ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
      auth: false, // No token needed for login
    );

    // Save tokens securely
    final data = response['data'];
    await _secureStorage.saveAccessToken(data['tokens']['accessToken']);
    await _secureStorage.saveRefreshToken(data['tokens']['refreshToken']);

    return data['user'];
  }

  // --- Register ---
  Future<Map<String, dynamic>> register(String email, String password,
      {List<String>? goals, List<String>? restrictions}) async {
    final response = await _apiService.post(
      Endpoints.register,
      body: {
        'email': email,
        'password': password,
        'dietary_goals': goals,
        'restrictions': restrictions,
      },
      auth: false,
    );

    final data = response['data'];
    await _secureStorage.saveAccessToken(data['tokens']['accessToken']);
    await _secureStorage.saveRefreshToken(data['tokens']['refreshToken']);

    return data['user'];
  }

  // --- Check if Logged In ---
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    // In a real app, we might check token expiration here using jwt_decoder
    return token != null;
  }

  // --- Logout ---
  Future<void> logout() async {
    try {
      // Tell backend to invalidate (optional, fire-and-forget)
      await _apiService.post(Endpoints.logout);
    } catch (_) {
      // Ignore network errors during logout
    } finally {
      // Always wipe local credentials
      await _secureStorage.clearAll();
    }
  }
}
