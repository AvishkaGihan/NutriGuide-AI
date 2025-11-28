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
    return RecipeModel(
      id: json['id'] as String? ?? '', // Fallback for stability
      name: json['name'] as String? ?? 'Untitled Recipe',

      // Parse Ingredients List
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientModel.fromJson(e))
              .toList() ??
          [],

      // Parse Instructions List
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      // Parse Nested Nutrition Object
      nutrition: NutritionModel.fromJson(
          json['nutrition'] as Map<String, dynamic>? ?? {}),

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
      name: json['name'] as String,
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
