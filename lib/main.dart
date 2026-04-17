import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp will be uncommented in Task 3
  runApp(const ProviderScope(child: LeftoverRouletteApp()));
}

class LeftoverRouletteApp extends ConsumerWidget {
  const LeftoverRouletteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
