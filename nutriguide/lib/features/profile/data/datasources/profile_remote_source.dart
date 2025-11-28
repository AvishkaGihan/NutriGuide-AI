import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<void> deleteAccount();
  Future<Map<String, dynamic>> exportData();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService _apiService;

  ProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _apiService.get(Endpoints.profile);
    // Response: { success: true, data: { ...profile_data... } }
    return ProfileModel.fromJson(response['data']);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await _apiService.put(
      Endpoints.profile,
      body: profile.toJson(), // Sends only updatable fields
    );
    return ProfileModel.fromJson(response['data']);
  }

  @override
  Future<void> deleteAccount() async {
    await _apiService.delete(Endpoints.deleteAccount);
  }

  @override
  Future<Map<String, dynamic>> exportData() async {
    final response = await _apiService.get(Endpoints.exportData);
    return response['data'];
  }
}
