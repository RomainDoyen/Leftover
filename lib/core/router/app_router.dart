import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/recipe_match.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/result/result_screen.dart';
import '../../presentation/screens/shopping/shopping_screen.dart';
import '../../presentation/screens/cooking/cooking_screen.dart';

abstract class Routes {
  static const home     = '/';
  static const result   = '/result';
  static const shopping = '/shopping';
  static const cooking  = '/cooking';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: const Center(child: Text('Page introuvable')),
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.shopping,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShoppingScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.result,
        builder: (context, state) => ResultScreen(
          match: state.extra is RecipeMatch ? state.extra as RecipeMatch : null,
        ),
      ),
      GoRoute(
        path: Routes.cooking,
        builder: (context, state) => CookingScreen(
          match: state.extra is RecipeMatch ? state.extra as RecipeMatch : null,
        ),
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(currentLocation: location),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String currentLocation;
  const _BottomNav({required this.currentLocation});

  static const _destinations = [
    (icon: Icons.casino_outlined, filledIcon: Icons.casino,      label: 'Spin',     path: Routes.home),
    (icon: Icons.shopping_basket_outlined, filledIcon: Icons.shopping_basket, label: 'Shopping', path: Routes.shopping),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _destinations.indexWhere(
      (d) => d.path == currentLocation,
    );

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (i) => context.go(_destinations[i].path),
      destinations: _destinations.map((d) => NavigationDestination(
        icon: Icon(d.icon),
        selectedIcon: Icon(d.filledIcon),
        label: d.label,
      )).toList(),
    );
  }
}
