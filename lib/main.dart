import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medtalk/config/routes.dart';
import 'package:medtalk/config/theme.dart';
import 'package:medtalk/services/gemini_service.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('GEMINI_API_KEY not found in .env file');
  }
  
  GeminiService().initialize(apiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MedTalk',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
