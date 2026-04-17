import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'presentation/theme/app_theme.dart';

const _useFirebase = bool.fromEnvironment('USE_FIREBASE');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(const ProviderScope(child: LeftoverRouletteApp()));
}

class LeftoverRouletteApp extends StatelessWidget {
  const LeftoverRouletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leftover Roulette',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Leftover Roulette')),
        body: const Center(child: Text('Ready to cook!')),
      ),
    );
  }
}
