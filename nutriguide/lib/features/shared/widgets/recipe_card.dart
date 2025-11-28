import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';
import 'package:nutriguide/features/recipes/presentation/pages/recipe_detail_screen.dart';
import 'package:nutriguide/features/shared/widgets/macro_gauge.dart';

class SharedRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const SharedRecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                image: recipe.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(recipe.imageUrl!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: recipe.imageUrl == null
                  ? const Center(
                      child: Icon(Icons.restaurant_menu,
                          size: 40, color: Colors.grey))
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Metadata
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${recipe.totalTimeMinutes} min',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.whatshot,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('${recipe.nutrition.calories.round()} kcal',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Macros Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MacroGauge(
                        label: 'Protein',
                        value: recipe.nutrition.proteinG,
                        unit: 'g',
                        totalCalories: recipe.nutrition.calories,
                        macroType: 'protein',
                        color: AppColors.primary,
                      ),
                      MacroGauge(
                        label: 'Carbs',
                        value: recipe.nutrition.carbsG,
                        unit: 'g',
                        totalCalories: recipe.nutrition.calories,
                        macroType: 'carb',
                        color: AppColors.accent,
                      ),
                      MacroGauge(
                        label: 'Fat',
                        value: recipe.nutrition.fatG,
                        unit: 'g',
                        totalCalories: recipe.nutrition.calories,
                        macroType: 'fat',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
