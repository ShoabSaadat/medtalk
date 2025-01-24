import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medtalk/models/chat_message.dart';
import 'package:medtalk/services/gemini_service.dart';
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
  bool _isLoading = false;

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

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _messages.add(
        ChatMessage(
          content: text,
          role: MessageRole.user,
        ),
      );
    });
    _scrollToBottom();

    // Get message history except the last message
    final history = _messages.length > 1 
        ? _messages.sublist(0, _messages.length - 1)
        : <ChatMessage>[];

    try {
      final response = await GeminiService().chat(text, history);
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            content: response,
            role: MessageRole.assistant,
          ),
        );
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handleVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
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
      body: Stack(
        children: [
          Column(
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
