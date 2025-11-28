import 'package:fpdart/fpdart.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  /// Sends a message to the AI and returns a Stream of updates.
  ///
  /// The Stream emits [Either<Failure, ChatStreamResult>].
  /// - On success: It yields partial text tokens, then finally the complete message.
  /// - On failure: It yields a Failure object.
  Stream<Either<Failure, ChatStreamResult>> sendMessage(
    String message, {
    String? conversationId,
  });

  /// Retrieves the past conversation history from local cache or remote server.
  Future<Either<Failure, List<ChatMessage>>> getChatHistory();
}
