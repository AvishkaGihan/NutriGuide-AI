import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';
import 'package:nutriguide/features/recipes/presentation/pages/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder (or actual image if URL exists)
            Container(
              height: 140,
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
                      child:
                          Icon(Icons.restaurant, color: Colors.grey, size: 40))
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Metadata Row
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTimeMinutes}m',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 16),
                      if (recipe.dietaryTags.isNotEmpty) ...[
                        const Icon(Icons.label_outline,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe.dietaryTags.first,
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Macro Snapshot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroBadge(
                          '${recipe.nutrition.calories.round()} kcal',
                          AppColors.warning),
                      _buildMacroBadge(
                          '${recipe.nutrition.proteinG.round()}g Pro',
                          AppColors.primary),
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

  Widget _buildMacroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
