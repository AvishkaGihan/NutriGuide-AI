import 'package:nutriguide/features/auth/domain/entities/user.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

class TestFixtures {
  TestFixtures._();

  // --- User ---
  static const tUser = User(
    id: 'user-123',
    email: 'test@example.com',
    dietaryGoals: ['weight_loss'],
    restrictions: ['vegan'],
    allergies: [],
  );

  // --- Recipe ---
  static const tNutrition = Nutrition(
    calories: 500,
    proteinG: 30,
    carbsG: 45,
    fatG: 20,
  );

  static const tIngredient =
      Ingredient(name: 'Chicken', quantity: '100', unit: 'g');

  static final tRecipe = Recipe(
    id: 'recipe-123',
    name: 'Test Recipe',
    ingredients: const [tIngredient],
    instructions: const ['Step 1'],
    nutrition: tNutrition,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    servings: 2,
    dietaryTags: const ['high_protein'],
    createdAt: DateTime(2025, 1, 1),
  );

  // --- Chat ---
  static final tChatMessageUser = ChatMessage(
    id: 'msg-1',
    role: MessageRole.user,
    content: 'Hello',
    timestamp: DateTime(2025, 1, 1, 10, 0),
  );

  static final tChatMessageAi = ChatMessage(
    id: 'msg-2',
    role: MessageRole.assistant,
    content: 'Hi there!',
    timestamp: DateTime(2025, 1, 1, 10, 1),
  );
}
