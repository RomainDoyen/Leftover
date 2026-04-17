import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/recipe_match.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/cooking_timer.dart';
import 'widgets/recipe_step_card.dart';

class CookingScreen extends StatefulWidget {
  final RecipeMatch? match;
  const CookingScreen({super.key, this.match});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  int _activeStep = 0;

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuisine')),
        body: const Center(child: Text('Aucune recette sélectionnée')),
      );
    }

    final recipe = match.recipe;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Leftover Roulette',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'CHOIX DU CHEF',
                      style: TextStyle(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  recipe.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),

                // Meta row
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.cookTimeMinutes} min',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.bolt,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      recipe.difficulty,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bento stats
                Row(
                  children: [
                    _StatCard(
                      label: 'Économisé',
                      value: '${match.matchPercent}%',
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Portions',
                      value: '${recipe.servingsMin}–${recipe.servingsMax}',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Timer header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Préparation',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    CookingTimer(initialMinutes: recipe.cookTimeMinutes),
                  ],
                ),
                const SizedBox(height: 20),

                // Steps
                ...recipe.steps.asMap().entries.map(
                      (e) => GestureDetector(
                        onTap: () => setState(() => _activeStep = e.key),
                        child: RecipeStepCard(
                          step: e.value,
                          isActive: e.key == _activeStep,
                        ),
                      ),
                    ),
                const SizedBox(height: 16),

                // Pro tip
                if (match.matchedIngredients.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.secondary, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Conseil : Tu as déjà '
                            '${match.matchedIngredients.map((i) => i.name).join(", ")} '
                            '— utilise-les en premier pour éviter le gaspillage.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
