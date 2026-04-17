import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'presentation/theme/app_theme.dart';
import 'core/router/app_router.dart';

const _useFirebase = bool.fromEnvironment('USE_FIREBASE');

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash visible while app initializes.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  if (_useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: LeftoverRouletteApp()));
}

class LeftoverRouletteApp extends ConsumerWidget {
  const LeftoverRouletteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Leftover Roulette',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
