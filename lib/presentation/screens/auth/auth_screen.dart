import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscure        = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isRegister => _tabs.index == 1;

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;

    if (_isRegister && password != _confirmCtrl.text) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isRegister) {
      await notifier.signUpWithEmail(email, password);
    } else {
      await notifier.signInWithEmail(email, password);
    }

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state is AsyncError) {
      _showError(AuthNotifier.friendlyError(state.error));
    }
  }

  Future<void> _googleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state is AsyncError) {
      _showError(AuthNotifier.friendlyError(state.error));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Leftover Roulette',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Center(
                child: Text(
                  'Transforme tes restes en plats savoureux.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // ── Tabs ──────────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabs,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Connexion'),
                    Tab(text: 'Inscription'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Fields ────────────────────────────────────────────────────
              _Field(
                controller: _emailCtrl,
                label: 'Adresse e-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _passwordCtrl,
                label: 'Mot de passe',
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_isRegister) ...[
                const SizedBox(height: 14),
                _Field(
                  controller: _confirmCtrl,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // ── Submit button ─────────────────────────────────────────────
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _isRegister ? "Créer mon compte" : "Se connecter",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Divider ───────────────────────────────────────────────────
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ou',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant)),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 20),

              // ── Google button ─────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _googleSignIn,
                  icon: const _GoogleIcon(),
                  label: const Text(
                    'Continuer avec Google',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Private widgets ─────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// SVG-free Google "G" icon drawn with text.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}
