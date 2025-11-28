import 'dart:typed_data';
import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/features/photos/data/models/photo_model.dart';

abstract class PhotoRemoteDataSource {
  Future<PhotoModel> analyzePhoto(Uint8List imageBytes, String filename);
  Future<List<PhotoModel>> getPhotoHistory();
  Future<void> deletePhoto(String id);
}

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final ApiService _apiService;

  PhotoRemoteDataSourceImpl(this._apiService);

  @override
  Future<PhotoModel> analyzePhoto(Uint8List imageBytes, String filename) async {
    final response = await _apiService.uploadPhoto(
      Endpoints.analyzePhoto,
      imageBytes,
      filename,
    );

    // Response: { success: true, data: { scanId, ingredients, suggestedRecipes... } }
    return PhotoModel.fromJson(response['data']);
  }

  @override
  Future<List<PhotoModel>> getPhotoHistory() async {
    // Placeholder endpoint, assuming implementation in future
    // For MVP, we might rely on local storage or implement /photos/history on backend later
    try {
      final response = await _apiService.get('/photos/history');
      final list = response['data'] as List<dynamic>;
      return list.map((e) => PhotoModel.fromJson(e)).toList();
    } catch (e) {
      // Return empty list if endpoint not ready yet
      return [];
    }
  }

  @override
  Future<void> deletePhoto(String id) async {
    await _apiService.delete('/photos/$id');
  }
}