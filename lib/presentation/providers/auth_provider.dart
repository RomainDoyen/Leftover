import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Stream of the current Firebase user — null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// ChangeNotifier that fires on every auth state change.
/// Used as GoRouter's refreshListenable so redirects are re-evaluated.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier();
});

// ─── Auth actions ────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _auth.createUserWithEmailAndPassword(
          email: email, password: password),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Connexion Google annulée.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    });
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    state = const AsyncData(null);
  }

  /// Human-readable French message from a FirebaseAuthException code.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-not-found'        => 'Aucun compte avec cet e-mail.',
        'wrong-password'        => 'Mot de passe incorrect.',
        'invalid-credential'    => 'E-mail ou mot de passe incorrect.',
        'email-already-in-use'  => 'Cette adresse e-mail est déjà utilisée.',
        'weak-password'         => 'Le mot de passe doit faire au moins 6 caractères.',
        'invalid-email'         => 'Adresse e-mail invalide.',
        'too-many-requests'     => 'Trop de tentatives. Réessaie dans quelques minutes.',
        'network-request-failed'=> 'Erreur réseau. Vérifie ta connexion.',
        _                       => 'Erreur : ${error.message}',
      };
    }
    return error.toString();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
