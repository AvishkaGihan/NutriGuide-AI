import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

abstract class RecipeRepository {
  /// Fetches the user's saved or history of recipes.
  Future<Either<Failure, List<Recipe>>> getMyRecipes();

  /// Fetches a specific recipe by ID.
  Future<Either<Failure, Recipe>> getRecipeById(String id);

  /// Requests a variation of an existing recipe (e.g., "Make it vegan").
  Future<Either<Failure, Recipe>> generateVariation(
      String id, String modification);
}
