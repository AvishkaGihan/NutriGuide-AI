import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nutriguide/features/chat/domain/entities/chat_message.dart';
import 'package:nutriguide/features/chat/domain/repositories/chat_repository.dart';
import 'package:nutriguide/features/chat/presentation/providers/chat_provider.dart';
import '../../../helpers/mockito_dummies.dart';

@GenerateMocks([ChatRepository])
import 'chat_provider_test.mocks.dart'; // Uncomment after running: flutter pub run build_runner build

void main() {
  late MockChatRepository mockRepository;
  late ProviderContainer container;

  setUpAll(registerMockitoDummies);

  setUp(() {
    mockRepository = MockChatRepository();
    container = ProviderContainer(overrides: [
      chatRepositoryProvider.overrideWithValue(mockRepository),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  group('ChatNotifier', () {
    test('initial state should be loading', () {
      // Since notifier loads history on init, it starts loading
      when(mockRepository.getChatHistory())
          .thenAnswer((_) async => const Right([]));

      final state = container.read(chatProvider);
      expect(state, const AsyncValue<List<ChatMessage>>.loading());
    });

    test('sendMessage should update state with streaming tokens', () async {
      // Arrange history load
      when(mockRepository.getChatHistory())
          .thenAnswer((_) async => const Right([]));

      // Wait for init
      await Future.delayed(Duration.zero);

      // Arrange stream
      const streamResult1 = ChatStreamResult(token: 'Hello');
      const streamResult2 = ChatStreamResult(token: ' World');

      when(mockRepository.sendMessage(any))
          .thenAnswer((_) => Stream.fromIterable([
                const Right(streamResult1),
                const Right(streamResult2),
              ]));

      // Act
      final notifier = container.read(chatProvider.notifier);
      await notifier.sendMessage('Hi');

      // Assert
      final state = container.read(chatProvider);
      // We expect the final state to contain one message with combined text
      final messages = state.value!;
      expect(messages.length, 1);
      expect(messages.first.content, 'Hello World');
      expect(messages.first.role, MessageRole.assistant);
    });
  });
}
