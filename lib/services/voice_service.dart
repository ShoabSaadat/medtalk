import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  final _recorder = AudioRecorder();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String? _recordingPath;

  factory VoiceService() {
    return _instance;
  }

  VoiceService._internal();

  Future<void> initialize() async {
    // Initialize speech to text
    _speechEnabled = await _speechToText.initialize();
    
    // Request permissions
    await [
      Permission.microphone,
      Permission.speech,
      Permission.storage,
    ].request();
  }

  Future<bool> startRecording() async {
    final hasPermission = await Permission.microphone.isGranted;
    if (hasPermission) {
      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/audio_message.wav';
      
      try {
        if (_recordingPath == null) return false;
        
        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            numChannels: 1, // Mono audio as required
            sampleRate: 16000, // Required by Gemini
          ),
          path: _recordingPath!,
        );
        developer.log('Started recording at: $_recordingPath');
        return true;
      } catch (e) {
        developer.log('Error starting recording: $e');
        return false;
      }
    }
    return false;
  }

  Future<String?> stopRecording() async {
    try {
      await _recorder.stop();
      developer.log('Stopped recording');
      return _recordingPath;
    } catch (e) {
      developer.log('Error stopping recording: $e');
      return null;
    }
  }

  Future<String?> startListening() async {
    if (!_speechEnabled) {
      developer.log('Speech to text not initialized');
      return null;
    }

    String recognizedText = '';
    bool isDone = false;
    
    try {
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            recognizedText = result.recognizedWords;
            isDone = true;
          }
        },
        listenFor: const Duration(seconds: 30),
        localeId: 'en_US',
        cancelOnError: true,
        partialResults: true,
      );

      // Wait for final result or timeout
      int attempts = 0;
      while (!isDone && attempts < 60) { // Wait up to 6 seconds
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      return recognizedText.isNotEmpty ? recognizedText : null;
    } catch (e) {
      developer.log('Error in speech recognition: $e');
      return null;
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<bool> get isRecording => _recorder.isRecording();
  bool get isListening => _speechToText.isListening;

  Future<void> dispose() async {
    await _recorder.dispose();
    // Clean up temporary recording if exists
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
