import 'package:equatable/equatable.dart';
// Note: This imports the Recipe entity (created in previous steps)
// because a photo scan can immediately suggest recipes.
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

class Photo extends Equatable {
  final String id;
  final List<String> ingredientsDetected;
  final List<Recipe>? suggestedRecipes;
  final DateTime createdAt;

  const Photo({
    required this.id,
    required this.ingredientsDetected,
    this.suggestedRecipes,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, ingredientsDetected, suggestedRecipes, createdAt];
}
