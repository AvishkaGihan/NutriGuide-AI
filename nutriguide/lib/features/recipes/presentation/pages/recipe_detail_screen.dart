import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  // In a real app, this would be adjustable via slider
  int _currentServings = 1;

  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.servings;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Container(
                color: Colors.grey[300],
                child: recipe.imageUrl != null
                    ? Image.network(recipe.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.restaurant,
                        size: 80, color: Colors.grey),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Prep', '${recipe.prepTimeMinutes}m'),
                      _buildStatColumn('Cook', '${recipe.cookTimeMinutes}m'),
                      _buildStatColumn('Serves', '$_currentServings'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Nutrition Grid
                  Text('Nutrition per serving',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildNutritionCard(
                              'Calories',
                              '${recipe.nutrition.calories.round()}',
                              AppColors.warning)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildNutritionCard(
                              'Protein',
                              '${recipe.nutrition.proteinG.round()}g',
                              AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildNutritionCard(
                              'Carbs',
                              '${recipe.nutrition.carbsG.round()}g',
                              AppColors.accent)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildNutritionCard(
                              'Fat',
                              '${recipe.nutrition.fatG.round()}g',
                              AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Ingredients
                  Text('Ingredients',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.ingredients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final ing = recipe.ingredients[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ing.displayString,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Instructions
                  Text('Instructions',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.instructions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                recipe.instructions[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Save to Favorites'),
                      onPressed: () {
                        // TODO: Implement Save Logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildNutritionCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
