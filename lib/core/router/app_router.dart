import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/recipe_match.dart';
import '../../env.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/onboarding_provider.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/result/result_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/how_it_works/how_it_works_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/shopping/shopping_screen.dart';
import '../../presentation/screens/cooking/cooking_screen.dart';

abstract class Routes {
  static const onboarding = '/onboarding';
  static const auth       = '/auth';
  static const home       = '/';
  static const result     = '/result';
  static const shopping   = '/shopping';
  static const history    = '/history';
  static const profile    = '/profile';
  static const editProfile = '/profile/edit';
  static const howItWorks = '/how-it-works';
  static const cooking    = '/cooking';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Watch both auth and onboarding notifiers so the router re-evaluates
  // redirects whenever either state changes.
  final onboardingNotifier = ref.watch(onboardingChangeNotifierProvider);
  final authNotifier =
      Env.useFirebase ? ref.watch(authChangeNotifierProvider) : null;
  final refreshListenable = authNotifier != null
      ? Listenable.merge([authNotifier, onboardingNotifier])
      : onboardingNotifier;

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // 1 ── Onboarding: shown at every launch (in-memory flag).
      final onboardingSeen = ref.read(onboardingSeenSyncProvider);
      if (!onboardingSeen && loc != Routes.onboarding) {
        return Routes.onboarding;
      }
      if (onboardingSeen && loc == Routes.onboarding) {
        return Env.useFirebase ? Routes.auth : Routes.home;
      }

      // 2 ── Auth guard (Firebase mode only).
      if (Env.useFirebase) {
        final user = FirebaseAuth.instance.currentUser;
        final onAuth = loc == Routes.auth;
        if (user == null && !onAuth && loc != Routes.onboarding) {
          return Routes.auth;
        }
        if (user != null && onAuth) return Routes.home;
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: const Center(child: Text('Page introuvable')),
    ),
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
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
          GoRoute(
            path: Routes.history,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.howItWorks,
        builder: (context, state) => const HowItWorksScreen(),
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
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft:  Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: _BottomNav(currentLocation: location),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String currentLocation;
  const _BottomNav({required this.currentLocation});

  static const _destinations = [
    (icon: Icons.casino_outlined,          filledIcon: Icons.casino,           label: 'Lancer',     path: Routes.home),
    (icon: Icons.history_outlined,         filledIcon: Icons.history_rounded,  label: 'Historique', path: Routes.history),
    (icon: Icons.shopping_basket_outlined, filledIcon: Icons.shopping_basket,  label: 'Courses',    path: Routes.shopping),
    (icon: Icons.person_outline_rounded,   filledIcon: Icons.person_rounded,   label: 'Profil',     path: Routes.profile),
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
