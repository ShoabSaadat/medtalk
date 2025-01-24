import 'package:flutter/material.dart';
import 'package:medtalk/config/theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onVoiceInput;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onVoiceInput,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();
  bool _isComposing = false;

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    widget.onSendMessage(text.trim());
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onVoiceInput,
                icon: const Icon(Icons.mic),
                color: AppTheme.primaryColor,
                tooltip: 'Voice Input',
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: _handleSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Ask your medical question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: _isComposing ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                  icon: const Icon(Icons.send),
                  color: AppTheme.primaryColor,
                  tooltip: 'Send Message',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
