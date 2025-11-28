import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final Nutrition nutrition;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final List<String> dietaryTags;
  final List<String>? allergenWarnings;
  final String? imageUrl;
  final DateTime? createdAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.dietaryTags,
    this.allergenWarnings,
    this.imageUrl,
    this.createdAt,
  });

  /// Helper to get total time formatted
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  @override
  List<Object?> get props => [
        id,
        name,
        ingredients,
        instructions,
        nutrition,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        dietaryTags,
        allergenWarnings,
        imageUrl,
        createdAt,
      ];
}

class Ingredient extends Equatable {
  final String name;
  final String? quantity;
  final String? unit;

  const Ingredient({
    required this.name,
    this.quantity,
    this.unit,
  });

  @override
  List<Object?> get props => [name, quantity, unit];

  /// Helper to display full string e.g. "2 cups Rice"
  String get displayString {
    final qty = quantity ?? '';
    final u = unit ?? '';
    if (qty.isEmpty && u.isEmpty) return name;
    return '$qty $u $name'.trim();
  }
}

class Nutrition extends Equatable {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const Nutrition({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  @override
  List<Object?> get props => [calories, proteinG, carbsG, fatG];
}
