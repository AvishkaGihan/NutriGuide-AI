import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/core/utils/nutrition_calculator.dart';

class MacroGauge extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double totalCalories;
  final String macroType; // 'protein', 'carb', 'fat'
  final Color color;

  const MacroGauge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.totalCalories,
    required this.macroType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage of total calories
    final percentage = NutritionCalculator.calculateMacroPercentage(
      macroGrams: value,
      totalCalories: totalCalories,
      macroType: macroType,
    );

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                strokeWidth: 4,
              ),
            ),
            Text(
              '${percentage.round()}%',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        Text(
          '${value.round()}$unit',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
