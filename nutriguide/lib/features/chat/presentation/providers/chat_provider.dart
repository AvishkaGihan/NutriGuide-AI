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

    await for (final result in stream) {
      result.fold(
        (failure) {
          // Handle error (maybe add a system message or toast)
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (streamResult) {
          final messages = List<ChatMessage>.from(state.value ?? []);

          if (streamResult.message != null) {
            // New complete message (User sent or AI finished)
            // Or "optimistic" user message

            // Check if we need to replace a placeholder or add new
            final existingIndex =
                messages.indexWhere((m) => m.id == streamResult.message!.id);
            if (existingIndex != -1) {
              messages[existingIndex] = streamResult.message!;
            } else {
              messages.add(streamResult.message!);
            }
            state = AsyncValue.data(messages);
          } else if (streamResult.token != null) {
            // Streaming token update for the LAST message (AI is typing)
            if (messages.isNotEmpty && !messages.last.isUser) {
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
            } else {
              // First token received, create placeholder AI message
              final aiMsg = ChatMessage(
                id: 'temp-ai-${DateTime.now().millisecondsSinceEpoch}',
                role: MessageRole.assistant,
                content: streamResult.token!,
                timestamp: DateTime.now(),
              );
              messages.add(aiMsg);
              state = AsyncValue.data(messages);
            }
          }
        },
      );
    }
  }
}
