import 'package:flutter_test/flutter_test.dart';
import 'package:nutriguide/core/utils/nutrition_calculator.dart';

void main() {
  group('NutritionCalculator', () {
    test('scaleValue should double values when servings double', () {
      final result = NutritionCalculator.scaleValue(
        originalValue: 100,
        originalServings: 2,
        newServings: 4,
      );
      expect(result, 200.0);
    });

    test('scaleValue should handle zero servings gracefully', () {
      final result = NutritionCalculator.scaleValue(
        originalValue: 100,
        originalServings: 0,
        newServings: 2,
      );
      expect(result, 100.0); // Should return original if invalid input
    });

    test('calculateMacroPercentage should calculate protein correctly', () {
      // 25g Protein * 4 cal/g = 100 cal. Total 400 cal. = 25%
      final result = NutritionCalculator.calculateMacroPercentage(
        macroGrams: 25,
        totalCalories: 400,
        macroType: 'protein',
      );
      expect(result, 25.0);
    });

    test('calculateMacroPercentage should return 0 for unknown macro type', () {
      final result = NutritionCalculator.calculateMacroPercentage(
        macroGrams: 10,
        totalCalories: 100,
        macroType: 'unknown',
      );
      expect(result, 0.0);
    });
  });
}
