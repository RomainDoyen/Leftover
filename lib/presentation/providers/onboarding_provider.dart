import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory flag — resets to false on every app launch so onboarding
/// always shows before the auth screen.
final onboardingSeenSyncProvider = StateProvider<bool>((ref) => false);

/// ChangeNotifier that lets GoRouter react when onboarding is completed.
class OnboardingChangeNotifier extends ChangeNotifier {
  void markSeen() => notifyListeners();
}

final onboardingChangeNotifierProvider =
    Provider<OnboardingChangeNotifier>((ref) => OnboardingChangeNotifier());

/// Marks onboarding as done for this session (no persistence).
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markSeen() {
    state = true;
    ref.read(onboardingSeenSyncProvider.notifier).state = true;
    ref.read(onboardingChangeNotifierProvider).markSeen();
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);
