import 'package:flutter/material.dart';
import 'package:medtalk/models/chat_message.dart';
import 'package:medtalk/widgets/chat_input.dart';
import 'package:medtalk/widgets/chat_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  void _handleSendMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          content: text,
          role: MessageRole.user,
        ),
      );
      // TODO: Implement Gemini API call here
      _messages.add(
        ChatMessage(
          content: 'This is a placeholder response. Gemini API will be integrated soon.',
          role: MessageRole.assistant,
        ),
      );
    });
    _scrollToBottom();
  }

  void _handleVoiceInput() {
    setState(() {
      _isListening = !_isListening;
      // TODO: Implement speech-to-text functionality
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedTalk Chat'),
        centerTitle: true,
        actions: [
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: const Center(
                child: Text(
                  'Listening...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask any medical question',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          ChatInput(
            onSendMessage: _handleSendMessage,
            onVoiceInput: _handleVoiceInput,
          ),
        ],
      ),
    );
  }
}
