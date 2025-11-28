import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/recipes/data/datasources/recipe_remote_source.dart';
import 'package:nutriguide/features/recipes/data/models/recipe_model.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';
import 'package:nutriguide/features/recipes/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource _remoteDataSource;
  final Box<dynamic> _recipeBox;

  RecipeRepositoryImpl(this._remoteDataSource, this._recipeBox);

  @override
  Future<Either<Failure, List<Recipe>>> getMyRecipes() async {
    try {
      // 1. Try Fetching from API
      final remoteRecipes = await _remoteDataSource.getMyRecipes();

      // 2. Cache them locally
      await _recipeBox.put(
          'recent_recipes', remoteRecipes.map((e) => e.toJson()).toList());

      return Right(remoteRecipes);
    } catch (e) {
      // 3. Fallback to Cache
      if (_recipeBox.containsKey('recent_recipes')) {
        final localData = _recipeBox.get('recent_recipes') as List<dynamic>;
        final localRecipes = localData
            .map((e) => RecipeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(localRecipes);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(String id) async {
    try {
      final recipe = await _remoteDataSource.getRecipeById(id);
      return Right(recipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Recipe>> generateVariation(
      String id, String modification) async {
    try {
      final newRecipe =
          await _remoteDataSource.generateVariation(id, modification);
      return Right(newRecipe);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
