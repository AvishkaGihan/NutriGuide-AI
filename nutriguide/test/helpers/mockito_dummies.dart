import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:nutriguide/core/utils/error_handler.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';

/// Register dummy values for Mockito to use when it cannot generate them automatically.
/// This is necessary for complex generic types like Either<Failure, T>.
void registerMockitoDummies() {
  // Provide a dummy Failure instance
  provideDummy<Failure>(const ServerFailure('dummy error'));

  // Provide a dummy ChatMessage instance
  provideDummy<ChatMessage>(
    ChatMessage(
      id: 'dummy-id',
      content: '',
      role: MessageRole.user,
      timestamp: DateTime(2025, 1, 1),
    ),
  );

  // Provide dummy Either types
  provideDummy<Either<Failure, List<ChatMessage>>>(
    const Right([]),
  );

  provideDummy<Either<Failure, ChatStreamResult>>(
    const Right(ChatStreamResult(token: '')),
  );
}
