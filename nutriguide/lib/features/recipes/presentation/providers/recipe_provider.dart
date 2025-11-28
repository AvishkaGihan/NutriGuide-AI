import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/logging_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/recipes/data/datasources/recipe_remote_source.dart';
import 'package:nutriguide/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';
import 'package:nutriguide/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:hive/hive.dart';

// --- Dependency Injection ---

final recipeRemoteSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSourceImpl(ApiService(
    secureStorage: SecureStorageService(),
    logger: LoggingService.instance,
  ));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final remoteSource = ref.watch(recipeRemoteSourceProvider);
  final recipeBox = Hive.box('recipe_storage'); // Ensure opened in main.dart
  return RecipeRepositoryImpl(remoteSource, recipeBox);
});

// For loading a specific recipe by ID
final recipeDetailProvider =
    FutureProvider.family<Recipe, String>((ref, id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  final result = await repository.getRecipeById(id);
  return result.fold(
    (failure) => throw failure.message,
    (recipe) => recipe,
  );
});

// For managing the list of "My Recipes"
final myRecipesProvider =
    StateNotifierProvider<MyRecipesNotifier, AsyncValue<List<Recipe>>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return MyRecipesNotifier(repository);
});

class MyRecipesNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final RecipeRepository _repository;

  MyRecipesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    final result = await _repository.getMyRecipes();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (recipes) => state = AsyncValue.data(recipes),
    );
  }
}
