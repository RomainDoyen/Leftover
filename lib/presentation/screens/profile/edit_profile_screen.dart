import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../env.dart';
import '../../providers/user_settings_provider.dart';
import '../../theme/app_colors.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (settings) => _EditProfileForm(
          initialMistralKey: settings.mistralApiKey,
        ),
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  final String initialMistralKey;
  const _EditProfileForm({required this.initialMistralKey});

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mistralCtrl;
  bool _obscureKey = true;
  bool _saving = false;
  bool _instructionsExpanded = true;

  @override
  void initState() {
    super.initState();
    final user = Env.useFirebase ? FirebaseAuth.instance.currentUser : null;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _mistralCtrl =
        TextEditingController(text: widget.initialMistralKey);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mistralCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (Env.useFirebase) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final name = _nameCtrl.text.trim();
          if (name.isNotEmpty && name != user.displayName) {
            await user.updateDisplayName(name);
            await user.reload();
          }
        }
      }
      await ref
          .read(userSettingsProvider.notifier)
          .saveMistralApiKey(_mistralCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil enregistré.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFirebaseUser =
        Env.useFirebase && FirebaseAuth.instance.currentUser != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasFirebaseUser) ...[
            const _SectionLabel('Identité'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                label: 'Nom affiché',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L\'e-mail est lié à ton compte et ne peut pas être modifié ici.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 28),
          ],
          const _SectionLabel('Génération IA (Mistral)'),
          const SizedBox(height: 8),
          Material(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => setState(
                  () => _instructionsExpanded = !_instructionsExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Comment obtenir ma clé API ?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(
                          _instructionsExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                    if (_instructionsExpanded) ...[
                      const SizedBox(height: 14),
                      const _InstructionStep(
                        number: 1,
                        text:
                            'Va sur console.mistral.ai et crée un compte (gratuit) ou connecte-toi.',
                      ),
                      _InstructionStep(
                        number: 2,
                        text:
                            'Ouvre la section « API keys » dans le menu latéral.',
                      ),
                      _InstructionStep(
                        number: 3,
                        text:
                            'Clique sur « Create new key », donne un nom (ex. Leftover).',
                      ),
                      _InstructionStep(
                        number: 4,
                        text:
                            'Copie la clé affichée — elle ne sera plus visible ensuite.',
                      ),
                      _InstructionStep(
                        number: 5,
                        text:
                            'Colle-la dans le champ ci-dessous puis enregistre.',
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        'https://console.mistral.ai',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ta clé reste sur ton téléphone : elle n\'est jamais stockée sur nos serveurs. Elle sert uniquement à appeler l\'API Mistral pour générer des recettes quand aucune ne correspond dans la base.',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mistralCtrl,
            obscureText: _obscureKey,
            autocorrect: false,
            enableSuggestions: false,
            decoration: _inputDecoration(
              label: 'Clé API Mistral',
              icon: Icons.key_outlined,
              suffix: IconButton(
                icon: Icon(
                  _obscureKey
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;
  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
