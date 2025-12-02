import 'dart:convert';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.ingredients,
    required super.instructions,
    required super.nutrition,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.servings,
    required super.dietaryTags,
    super.allergenWarnings,
    super.imageUrl,
    super.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse ingredients - could be List or JSON string
    List<IngredientModel> parseIngredients(dynamic ingredientsData) {
      if (ingredientsData == null) return [];

      List<dynamic> ingredientsList;
      if (ingredientsData is String) {
        // Parse JSON string
        ingredientsList = jsonDecode(ingredientsData) as List<dynamic>;
      } else if (ingredientsData is List) {
        ingredientsList = ingredientsData;
      } else {
        return [];
      }

      return ingredientsList
          .map((e) {
            if (e is Map<String, dynamic>) {
              return IngredientModel.fromJson(e);
            } else if (e is Map) {
              return IngredientModel.fromJson(Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<IngredientModel>()
          .toList();
    }

    // Helper function to parse instructions - could be List or JSON string
    List<String> parseInstructions(dynamic instructionsData) {
      if (instructionsData == null) return [];

      List<dynamic> instructionsList;
      if (instructionsData is String) {
        // Parse JSON string
        instructionsList = jsonDecode(instructionsData) as List<dynamic>;
      } else if (instructionsData is List) {
        instructionsList = instructionsData;
      } else {
        return [];
      }

      return instructionsList.map((e) => e.toString()).toList();
    }

    // Helper function to parse nutrition - could be Map or JSON string
    Map<String, dynamic> parseNutrition(dynamic nutritionData) {
      if (nutritionData == null) return {};

      if (nutritionData is String) {
        return jsonDecode(nutritionData) as Map<String, dynamic>;
      } else if (nutritionData is Map<String, dynamic>) {
        return nutritionData;
      } else if (nutritionData is Map) {
        return Map<String, dynamic>.from(nutritionData);
      }

      return {};
    }

    return RecipeModel(
      id: json['id']?.toString() ??
          '', // Convert to String, fallback for stability
      name: json['name'] as String? ?? 'Untitled Recipe',

      // Parse Ingredients List (handle both JSON string and List)
      ingredients: parseIngredients(json['ingredients']),

      // Parse Instructions List (handle both JSON string and List)
      instructions: parseInstructions(json['instructions']),

      // Parse Nested Nutrition Object (handle both JSON string and Map)
      nutrition: NutritionModel.fromJson(parseNutrition(json['nutrition'])),

      prepTimeMinutes: json['prep_time_minutes'] as int? ?? 0,
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,

      dietaryTags: (json['dietary_tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      allergenWarnings: (json['allergen_warnings'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),

      imageUrl:
          json['image_url'] as String?, // Might be null if not generated yet

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients':
          ingredients.map((e) => (e as IngredientModel).toJson()).toList(),
      'instructions': instructions,
      'nutrition': (nutrition as NutritionModel).toJson(),
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'dietary_tags': dietaryTags,
      'allergen_warnings': allergenWarnings,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.name,
    super.quantity,
    super.unit,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] as String? ?? '',
      quantity: json['quantity']?.toString(), // Handle number or string
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };
}

class NutritionModel extends Nutrition {
  const NutritionModel({
    required super.calories,
    required super.proteinG,
    required super.carbsG,
    required super.fatG,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
      };
}
