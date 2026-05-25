import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_settings_repository.dart';
import '../../env.dart';
import 'auth_provider.dart';

final userSettingsRepositoryProvider =
    Provider<UserSettingsRepository>((ref) => UserSettingsRepository());

final userSettingsProvider =
    AsyncNotifierProvider<UserSettingsNotifier, UserSettings>(
        UserSettingsNotifier.new);

/// True when the user has saved their own Mistral API key in Profil.
final hasUserMistralKeyProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider).valueOrNull;
  return settings?.hasMistralKey ?? false;
});

/// Clé Mistral effective : clé utilisateur, sinon repli sur env.dart (dev).
final effectiveMistralApiKeyProvider = Provider<String>((ref) {
  final settings = ref.watch(userSettingsProvider).valueOrNull;
  final userKey = settings?.mistralApiKey ?? '';
  if (userKey.isNotEmpty &&
      userKey != 'REMPLACE_PAR_TA_CLE_MISTRAL') {
    return userKey;
  }
  return Env.mistralApiKey;
});

class UserSettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    if (Env.useFirebase) {
      ref.listen(authStateProvider, (_, __) => ref.invalidateSelf());
    }
    final uid = _userId;
    if (uid == null) return const UserSettings();
    return ref.read(userSettingsRepositoryProvider).load(uid);
  }

  String? get _userId {
    if (Env.useFirebase) {
      return FirebaseAuth.instance.currentUser?.uid;
    }
    return 'local';
  }

  Future<void> saveMistralApiKey(String key) async {
    final uid = _userId;
    if (uid == null) return;
    await ref
        .read(userSettingsRepositoryProvider)
        .saveMistralApiKey(uid, key);
    state = AsyncData(UserSettings(mistralApiKey: key.trim()));
  }
}
