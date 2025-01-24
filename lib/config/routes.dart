import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medtalk/screens/landing_screen.dart';
import 'package:medtalk/screens/chat_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri.path}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  ),
);
