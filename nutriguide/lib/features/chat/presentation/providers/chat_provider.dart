import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/services/api_service.dart';
import 'package:nutriguide/core/services/logging_service.dart';
import 'package:nutriguide/core/services/secure_storage.dart';
import 'package:nutriguide/features/chat/data/datasources/chat_remote_source.dart';
import 'package:nutriguide/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';
import 'package:nutriguide/features/chat/domain/repositories/chat_repository.dart';
import 'package:hive/hive.dart';

// --- Dependency Injection ---

final chatRemoteSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(
    ApiService(
      secureStorage: SecureStorageService(),
      logger: LoggingService.instance,
    ),
    SecureStorageService(),
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteSource = ref.watch(chatRemoteSourceProvider);
  // Assuming Hive box is already opened in main.dart
  final chatBox = Hive.box('chat_storage');
  return ChatRepositoryImpl(remoteSource, chatBox);
});

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});

// --- Notifier Class ---

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final result = await _repository.getChatHistory();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (history) => state = AsyncValue.data(history),
    );
  }

  Future<void> sendMessage(String text) async {
    // We don't manually add the user message here because the repository stream
    // yields it as the first event (Optimistic UI pattern handled in Repo).

    // Listen to the stream
    final stream = _repository.sendMessage(text);
    bool aiMessageStarted =
        false; // Track if we've started receiving AI response tokens
    String tempAiMessageId = ''; // Track the temp AI message ID

    await for (final result in stream) {
      result.fold(
        (failure) {
          // Handle error (maybe add a system message or toast)
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (streamResult) {
          final messages = List<ChatMessage>.from(state.value ?? []);

          if (streamResult.message != null) {
            // Complete message arrived
            final msg = streamResult.message!;

            if (msg.isUser) {
              // User message - add it
              messages.add(msg);
            } else {
              // AI message - replace the temp placeholder if it exists
              if (aiMessageStarted && tempAiMessageId.isNotEmpty) {
                final existingIndex =
                    messages.indexWhere((m) => m.id == tempAiMessageId);
                if (existingIndex != -1) {
                  // Replace the temp placeholder with the complete message
                  messages[existingIndex] = msg;
                } else {
                  // Shouldn't happen, but add as fallback
                  messages.add(msg);
                }
              } else {
                // No temp message, just add the complete one
                messages.add(msg);
              }
              aiMessageStarted = false;
              tempAiMessageId = '';
            }

            state = AsyncValue.data(messages);
          } else if (streamResult.token != null) {
            // Streaming token update - append to the last message (AI is typing)
            if (messages.isNotEmpty && !messages.last.isUser) {
              // Continue updating existing AI message
              final lastMsg = messages.last;
              final updatedContent = lastMsg.content + streamResult.token!;

              messages.last = ChatMessage(
                id: lastMsg.id,
                role: lastMsg.role,
                content: updatedContent,
                timestamp: lastMsg.timestamp,
                recipe: lastMsg.recipe,
              );
              state = AsyncValue.data(messages);
            } else if (!aiMessageStarted) {
              // First token received, create placeholder AI message
              tempAiMessageId =
                  'temp-ai-${DateTime.now().millisecondsSinceEpoch}';
              final aiMsg = ChatMessage(
                id: tempAiMessageId,
                role: MessageRole.assistant,
                content: streamResult.token!,
                timestamp: DateTime.now(),
              );
              aiMessageStarted = true;
              messages.add(aiMsg);
              state = AsyncValue.data(messages);
            } else {
              // Update existing temp message
              if (messages.isNotEmpty) {
                final lastMsg = messages.last;
                final updatedContent = lastMsg.content + streamResult.token!;

                messages.last = ChatMessage(
                  id: lastMsg.id,
                  role: lastMsg.role,
                  content: updatedContent,
                  timestamp: lastMsg.timestamp,
                  recipe: lastMsg.recipe,
                );
                state = AsyncValue.data(messages);
              }
            }
          }
        },
      );
    }
  }
}
