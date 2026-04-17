import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/recipe_match.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/ingredient_list_item.dart';
import 'widgets/match_ring.dart';

class ResultScreen extends ConsumerWidget {
  final RecipeMatch? match;

  const ResultScreen({super.key, this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat')),
        body: const Center(child: Text('Aucun résultat')),
      );
    }

    final recipe = match!.recipe;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.imageUrl != null)
                    Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _HeroBackground(),
                    )
                  else
                    const _HeroBackground(),
                  Positioned(
                    top: 120,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'MATCH FOUND',
                        style: TextStyle(
                          color: AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black38)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Score + timer row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'STOCK STATUS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${match!.matchPercent}%',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 48,
                                  ),
                                ),
                                const Text(
                                  'de tes ingrédients',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            MatchRing(score: match!.matchScore),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryContainer
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: Colors.white, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              '${recipe.cookTimeMinutes}m',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                            const Text(
                              'Cook Time',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Ingredients header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ingrédients',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(
                      '${recipe.ingredients.length} items',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Matched ingredients
                if (match!.matchedIngredients.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'IN YOUR PANTRY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  ...match!.matchedIngredients.map(
                    (ing) => IngredientListItem(ingredient: ing, owned: true),
                  ),
                ],

                // Missing ingredients
                if (match!.missingIngredients.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'MISSING ITEMS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ...match!.missingIngredients.map(
                    (ing) => IngredientListItem(
                      ingredient: ing,
                      owned: false,
                      onAddToList: () => ref
                          .read(addToShoppingListUseCaseProvider)
                          .execute(ing, match!),
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // CTA buttons
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push(Routes.cooking, extra: match),
                    icon: const Icon(Icons.restaurant, color: Colors.white),
                    label: const Text(
                      'Start Cooking Now',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Spin Again'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
      ),
    );
  }
}
