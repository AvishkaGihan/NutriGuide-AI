import 'package:equatable/equatable.dart';
// Note: This import assumes the Recipe entity will be created in the next step.
// It is required because the AI can attach a generated recipe to a message.
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

enum MessageRole {
  user,
  assistant,
}

class ChatMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final Recipe? recipe; // Attached recipe if the AI generated one

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.recipe,
  });

  @override
  List<Object?> get props => [id, role, content, timestamp, recipe];

  /// Helper to check if the message is from the user
  bool get isUser => role == MessageRole.user;
}

/// A helper entity to handle the different states of a streaming response.
/// The stream can emit:
/// 1. A [token] (partial string for typing effect)
/// 2. A completed [message] (when the stream finishes)
class ChatStreamResult extends Equatable {
  final String? token;
  final ChatMessage? message;
  final bool isDone;

  const ChatStreamResult({
    this.token,
    this.message,
    this.isDone = false,
  });

  @override
  List<Object?> get props => [token, message, isDone];
}
