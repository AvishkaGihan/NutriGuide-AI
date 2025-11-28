import 'package:nutriguide/features/photos/domain/entities/photo.dart';
import 'package:nutriguide/features/recipes/data/models/recipe_model.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

class PhotoModel extends Photo {
  const PhotoModel({
    required super.id,
    required super.ingredientsDetected,
    super.suggestedRecipes,
    required super.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    // The API /analyze endpoint returns:
    // { "scanId": "...", "ingredients": [...], "suggestedRecipes": [...] }

    // The API /history endpoint might return:
    // { "id": "...", "ingredients_detected": [...], "created_at": "..." }

    final id = json['scanId'] ?? json['id'] ?? '';

    // Handle key variation between endpoints
    final ingredientsJson =
        json['ingredients'] ?? json['ingredients_detected'] ?? [];
    final List<String> ingredients = List<String>.from(ingredientsJson);

    final recipesJson = json['suggestedRecipes'] as List<dynamic>?;
    final recipes = recipesJson
        ?.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PhotoModel(
      id: id,
      ingredientsDetected: ingredients,
      suggestedRecipes: recipes?.cast<Recipe>(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredients_detected': ingredientsDetected,
      'created_at': createdAt.toIso8601String(),
      'suggestedRecipes':
          suggestedRecipes?.map((e) => (e as RecipeModel).toJson()).toList(),
    };
  }
}
