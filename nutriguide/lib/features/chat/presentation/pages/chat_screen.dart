import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/chat/presentation/providers/chat_provider.dart';
import 'package:nutriguide/features/chat/presentation/widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _controller.clear();
      ref.read(chatProvider.notifier).sendMessage(text);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Small delay to allow list to render
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriGuide Assistant'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat History
          Expanded(
            child: chatState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                // Auto-scroll logic listener could go here

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask about recipes, ingredients...',
                        hintStyle:
                            const TextStyle(color: AppColors.textTertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    mini: true,
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 48, color: AppColors.primary.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            'What can I help you cook?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try "Low carb dinner" or "High protein breakfast"',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
