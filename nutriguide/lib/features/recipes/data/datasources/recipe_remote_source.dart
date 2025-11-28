import 'package:nutriguide/core/constants/endpoints.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/features/recipes/data/models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getMyRecipes();
  Future<RecipeModel> getRecipeById(String id);
  Future<RecipeModel> generateVariation(String id, String modification);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final ApiService _apiService;

  RecipeRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<RecipeModel>> getMyRecipes() async {
    final response = await _apiService.get(Endpoints.recipes);
    // Response: { success: true, data: [...] }
    final list = response['data'] as List<dynamic>;
    return list.map((e) => RecipeModel.fromJson(e)).toList();
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    final response = await _apiService.get(Endpoints.recipeDetail(id));
    return RecipeModel.fromJson(response['data']);
  }

  @override
  Future<RecipeModel> generateVariation(String id, String modification) async {
    final response = await _apiService.post(
      Endpoints.recipeVariation(id),
      body: {'modificationRequest': modification},
    );
    return RecipeModel.fromJson(response['data']);
  }
}
