import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:medtalk/models/chat_message.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal();

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> chat(String message, List<ChatMessage> history) async {
    try {
      final chat = _model.startChat(
        history: history.map((msg) => Content.text(
          msg.content,
        )).toList(),
      );
      
      final response = await chat.sendMessage(Content.text(message));
      final responseText = response.text;
      
      if (responseText == null) {
        throw Exception('No response from Gemini');
      }
      
      return responseText;
    } catch (e) {
      throw Exception('Failed to get response: $e');
    }
  }
}
