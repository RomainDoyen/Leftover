import 'package:flutter/material.dart';
import '../../../presentation/theme/app_colors.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Comment ça marche ?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Intro
                const Text(
                  "Leftover transforme tes restes en repas.\nVoici comment ça se passe :",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Steps
                const _StepCard(
                  step: 1,
                  accentColor: AppColors.primary,
                  accentBackground: Color(0xFFFFDDD4),
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Saisis tes ingrédients',
                  description:
                      "Sur la page d'accueil, entre les ingrédients que tu as sous la main — pas besoin d'être exhaustif, 2 ou 3 suffisent pour démarrer.",
                ),
                const _StepCard(
                  step: 2,
                  accentColor: AppColors.secondary,
                  accentBackground: Color(0xFFCCF5D0),
                  icon: Icons.track_changes_rounded,
                  title: 'Trouve une recette',
                  description:
                      "L'appli compare tes ingrédients avec notre base de recettes et calcule un score de correspondance. Elle te dit exactement ce qu'il manque pour compléter la recette.",
                ),
                const _StepCard(
                  step: 3,
                  accentColor: AppColors.tertiary,
                  accentBackground: Color(0xFFEDD5F9),
                  icon: Icons.auto_awesome_rounded,
                  title: "L'IA prend le relais",
                  description:
                      "Si aucune recette de notre base ne correspond, notre IA (Mistral) génère une recette sur-mesure avec exactement tes ingrédients. Elle est ensuite sauvegardée pour les autres utilisateurs.",
                ),
                const _StepCard(
                  step: 4,
                  accentColor: Color(0xFF0077B6),
                  accentBackground: Color(0xFFCCE9F7),
                  icon: Icons.shopping_basket_outlined,
                  title: 'Complète ta liste de courses',
                  description:
                      "Les ingrédients manquants s'ajoutent en un tap à ta liste de courses. Retrouve-les dans l'onglet Courses pour ne rien oublier.",
                ),
                const _StepCard(
                  step: 5,
                  accentColor: Color(0xFFD4820A),
                  accentBackground: Color(0xFFFEEDD4),
                  icon: Icons.history_rounded,
                  title: 'Retrouve tes recettes',
                  description:
                      "Toutes les recettes que tu as générées sont conservées dans l'onglet Historique. Tu peux les relancer ou les cuisiner à tout moment.",
                ),

                const SizedBox(height: 32),
                const Divider(color: AppColors.outlineVariant),
                const SizedBox(height: 24),

                // Tip
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: AppColors.secondary, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Astuce : plus tu ajoutes d'ingrédients, meilleur sera le match. L'appli reconnaît les variantes (ex. \"oeufs\" = \"oeuf\").",
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final int step;
  final Color accentColor;
  final Color accentBackground;
  final IconData icon;
  final String title;
  final String description;

  const _StepCard({
    required this.step,
    required this.accentColor,
    required this.accentBackground,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number + icon
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$step',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
