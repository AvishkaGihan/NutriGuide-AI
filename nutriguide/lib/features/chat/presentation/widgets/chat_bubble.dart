import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/core/utils/date_formatter.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';
// Note: RecipeCard will be generated in the next step.
// We verify its import path here.
import 'package:nutriguide/features/recipes/presentation/widgets/recipe_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isUser ? AppColors.primary : AppColors.surface;
    final textColor = isUser ? Colors.white : AppColors.textDark;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            boxShadow: isUser
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    )
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatTime(message.timestamp),
                style: TextStyle(
                  color: isUser
                      ? Colors.white.withAlpha(179)
                      : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // Recipe Attachment
        if (message.recipe != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              // This widget will be available after next step
              child: RecipeCard(recipe: message.recipe!),
            ),
          ),
      ],
    );
  }
}
