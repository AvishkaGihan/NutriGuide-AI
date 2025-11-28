import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/chat/data/datasources/chat_remote_source.dart';
import 'package:nutriguide/features/chat/data/models/chat_message_model.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';
import 'package:nutriguide/features/chat/domain/repositories/chat_repository.dart';
import 'package:nutriguide/features/recipes/domain/entities/recipe.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final Box<dynamic> _chatBox; // Hive box for caching

  ChatRepositoryImpl(this._remoteDataSource, this._chatBox);

  @override
  Stream<Either<Failure, ChatStreamResult>> sendMessage(String message,
      {String? conversationId}) async* {
    try {
      // 1. Yield the user message immediately (optimistic UI)
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
        role: MessageRole.user,
        content: message,
        timestamp: DateTime.now(),
      );
      // Save to local cache
      await _saveMessageLocally(userMsg);
      yield Right(ChatStreamResult(message: userMsg));

      // 2. Stream the AI response
      String accumulatedText = '';
      Recipe? recipe;

      final stream = _remoteDataSource.streamMessage(message,
          conversationId: conversationId);

      await for (final event in stream) {
        if (event is String) {
          accumulatedText += event;
          // Yield partial update
          yield Right(ChatStreamResult(token: event));
        } else if (event is Recipe) {
          recipe = event;
        }
      }

      // 3. Finalize AI Message
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: accumulatedText,
        timestamp: DateTime.now(),
        recipe: recipe,
      );

      // Save complete AI message to cache
      await _saveMessageLocally(aiMsg);

      // Yield Final completion event
      yield Right(ChatStreamResult(message: aiMsg, isDone: true));
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory() async {
    try {
      // Try fetching from API
      final remoteHistory = await _remoteDataSource.getChatHistory();

      // Update local cache
      await _chatBox.put(
          'history', remoteHistory.map((e) => e.toJson()).toList());

      return Right(remoteHistory);
    } catch (e) {
      // Fallback to local cache if offline
      if (_chatBox.containsKey('history')) {
        final localData = _chatBox.get('history') as List<dynamic>;
        final localHistory = localData
            .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(localHistory);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _saveMessageLocally(ChatMessage message) async {
    // Basic caching implementation - append to list in Hive
    final List<dynamic> currentHistory =
        _chatBox.get('history', defaultValue: []) as List<dynamic>;

    // Convert entity to model for JSON serialization
    // In a real app, use a Mapper class. Here we cast/construct manually for brevity.
    final model = ChatMessageModel(
      id: message.id,
      role: message.role,
      content: message.content,
      timestamp: message.timestamp,
      recipe: message.recipe != null
          ? message.recipe as dynamic
          : null, // Handle casting carefully in real app
    );

    currentHistory.add(model.toJson());
    await _chatBox.put('history', currentHistory);
  }
}
