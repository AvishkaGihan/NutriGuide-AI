import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(String email, String password,
      {List<String>? goals, List<String>? restrictions});
  Future<void> logout();
}

/// Helper model to transport User + Tokens from the API response
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponseModel(
      {required this.user,
      required this.accessToken,
      required this.refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _apiService.post(
      Endpoints.login,
      body: {
        'email': email,
        'password': password,
      },
      auth: false, // Login is public
    );

    // Response structure from AuthController: { success: true, data: { user: {...}, tokens: {...} } }
    final data = response['data'];

    return AuthResponseModel(
      user: UserModel.fromJson(data['user']),
      accessToken: data['tokens']['accessToken'],
      refreshToken: data['tokens']['refreshToken'],
    );
  }

  @override
  Future<AuthResponseModel> register(String email, String password,
      {List<String>? goals, List<String>? restrictions}) async {
    final response = await _apiService.post(
      Endpoints.register,
      body: {
        'email': email,
        'password': password,
        'dietary_goals': goals,
        'restrictions': restrictions,
      },
      auth: false, // Register is public
    );

    final data = response['data'];

    return AuthResponseModel(
      user: UserModel.fromJson(data['user']),
      accessToken: data['tokens']['accessToken'],
      refreshToken: data['tokens']['refreshToken'],
    );
  }

  @override
  Future<void> logout() async {
    await _apiService.post(Endpoints.logout);
  }
}
