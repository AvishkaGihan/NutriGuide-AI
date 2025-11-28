class NutritionCalculator {
  NutritionCalculator._();

  // Calories per gram constants
  static const int _proteinCalPerGram = 4;
  static const int _carbCalPerGram = 4;
  static const int _fatCalPerGram = 9;

  /// Scales a nutrient value based on serving size adjustment
  /// e.g. If recipe is for 2 servings (value: 500) and user wants 4 servings, returns 1000.
  static double scaleValue({
    required num originalValue,
    required int originalServings,
    required int newServings,
  }) {
    if (originalServings <= 0) return originalValue.toDouble();
    final singleServingValue = originalValue / originalServings;
    return singleServingValue * newServings;
  }

  /// Calculates the percentage of total calories contributed by a macro
  /// Useful for "Macro Goal Alignment" charts
  static double calculateMacroPercentage({
    required double macroGrams,
    required double totalCalories,
    required String macroType, // 'protein', 'carb', 'fat'
  }) {
    if (totalCalories == 0) return 0.0;

    int calPerGram;
    switch (macroType) {
      case 'protein':
        calPerGram = _proteinCalPerGram;
        break;
      case 'carb':
        calPerGram = _carbCalPerGram;
        break;
      case 'fat':
        calPerGram = _fatCalPerGram;
        break;
      default:
        return 0.0;
    }

    final macroCalories = macroGrams * calPerGram;
    return (macroCalories / totalCalories) * 100;
  }

  /// Returns text color based on alignment with goal (Basic Logic)
  /// e.g. High protein is good for 'muscle_gain'
  static bool isMacroAligned(String goal, String macroType, double percentage) {
    if (goal == 'muscle_gain' && macroType == 'protein' && percentage > 30) {
      return true;
    }
    if (goal == 'weight_loss' && macroType == 'carb' && percentage < 40) {
      return true;
    }
    // Add more complex diet logic here as needed
    return false;
  }
}
