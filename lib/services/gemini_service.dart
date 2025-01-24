import 'dart:developer' as developer;
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

  Future<String> chat(
    String message,
    List<ChatMessage> history, {
    List<int>? audioData,
  }) async {
    developer.log('Starting chat request with message: $message');
    try {
      developer.log('Converting history to Gemini format');
      final geminiHistory = history.map((msg) => Content.text(msg.content)).toList();
      
      developer.log('Starting chat with Gemini');
      final chat = _model.startChat(history: geminiHistory);
      
      developer.log('Sending message to Gemini');
      final response = await chat.sendMessage(Content.text(message));
      final responseText = response.text;
      
      if (responseText == null) {
        throw Exception('No response from Gemini');
      }
      
      return responseText;
    } catch (e, stackTrace) {
      developer.log('Error in chat request', error: e, stackTrace: stackTrace);
      
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('socket') || 
          errorMsg.contains('failed host lookup') ||
          errorMsg.contains('network')) {
        throw Exception(
          'Network error: Unable to connect to Gemini servers.\n'
          'Please check:\n'
          '1. Your internet connection is working\n'
          '2. You have mobile data or WiFi enabled\n'
          '3. Try switching between WiFi and mobile data\n'
          '4. Restart the app if the problem persists'
        );
      } else if (errorMsg.contains('api key') || errorMsg.contains('unauthorized')) {
        throw Exception(
          'API key error: The API key is invalid or has expired.\n'
          'Please check the API key in your .env file.'
        );
      } else {
        throw Exception('Unexpected error: ${e.toString()}\n'
            'Please try again or contact support if the issue persists.');
      }
    }
  }
}
