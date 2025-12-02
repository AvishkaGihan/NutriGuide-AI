import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';
import 'package:nutriguide/features/recipes/data/models/recipe_model.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.timestamp,
    super.recipe,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Parse nested recipe if available
    RecipeModel? recipe;
    if (json['recipe'] != null) {
      // Handle recipe as Map
      if (json['recipe'] is Map<String, dynamic>) {
        recipe = RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>);
      } else if (json['recipe'] is Map) {
        recipe = RecipeModel.fromJson(
            Map<String, dynamic>.from(json['recipe'] as Map));
      }
    } else if (json['recipe_attached'] != null) {
      // Handle potential API naming variation
      if (json['recipe_attached'] is Map<String, dynamic>) {
        recipe = RecipeModel.fromJson(
            json['recipe_attached'] as Map<String, dynamic>);
      } else if (json['recipe_attached'] is Map) {
        recipe = RecipeModel.fromJson(
            Map<String, dynamic>.from(json['recipe_attached'] as Map));
      }
    }

    return ChatMessageModel(
      id: json['id']?.toString() ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Convert to String and provide fallback
      role: _parseRole(json['role']),
      content: json['content'] as String? ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      recipe: recipe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'created_at': timestamp.toIso8601String(),
      // We generally don't serialize the full recipe back to JSON here for the API,
      // but useful for local Hive storage if needed.
      'recipe': recipe != null ? (recipe as RecipeModel).toJson() : null,
    };
  }

  static MessageRole _parseRole(String? role) {
    if (role == 'user') return MessageRole.user;
    return MessageRole.assistant;
  }
}
