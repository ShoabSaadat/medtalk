enum MessageRole {
  user,
  assistant,
}

class ChatMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == MessageRole.user;
}
