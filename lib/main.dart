import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth.dart'; // Extracted onboarding/auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) print('Firebase init failed: $e');
  }

  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      if (kDebugMode) print('Uncaught error: $error');
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(
        path: '/next',
        builder: (context, state) =>
            const _SimpleScreen(title: 'Next Screen Placeholder'),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) =>
            const _SimpleScreen(title: 'Sign in Placeholder'),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
