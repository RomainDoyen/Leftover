// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/recipe_match.dart';
import '../../../presentation/providers/ingredient_provider.dart';
import '../../../presentation/providers/recipe_match_provider.dart';
import '../../../presentation/providers/trending_provider.dart';
import '../../../presentation/providers/user_settings_provider.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/ingredient_chip.dart';
import 'widgets/trending_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  bool _spinning = false;
  bool _generating = false; // true while calling Mistral AI

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    ref.read(ingredientProvider.notifier).add(text);
    _controller.clear();
  }

  Future<void> _spin() async {
    final ingredients = ref.read(ingredientProvider);
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute au moins un ingrédient !')),
      );
      return;
    }

    // ── 1. Match dans la base ──────────────────────────────────────────────
    setState(() => _spinning = true);
    await ref.read(recipeMatchProvider.notifier).spin();
    if (!mounted) return;
    setState(() => _spinning = false);

    final match = ref.read(bestMatchProvider);
    if (match != null) {
      context.push(Routes.result, extra: match);
      return;
    }

    // ── 2. Aucune recette trouvée → génération IA ─────────────────────────
    final canGenerate = ref.read(generateRecipeUseCaseProvider).isAvailable;
    if (!canGenerate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Aucune recette trouvée. Configure ta clé API Mistral dans Profil → Modifier mes informations.',
          ),
          action: SnackBarAction(
            label: 'Profil',
            onPressed: () => context.go(Routes.profile),
          ),
        ),
      );
      return;
    }

    setState(() => _generating = true);
    final generated = await ref.read(recipeMatchProvider.notifier).generate();
    if (!mounted) return;
    setState(() => _generating = false);

    if (generated) {
      final aiMatch = ref.read(bestMatchProvider);
      if (aiMatch != null && mounted) {
        context.push(Routes.result, extra: aiMatch);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'IA n\'a pas pu générer de recette. Réessaie !'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientProvider);
    final hasMistralKey = ref.watch(hasUserMistralKeyProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Leftover',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            actions: const [],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _HeroCard(),
                if (!hasMistralKey) ...[
                  const SizedBox(height: 16),
                  _MistralKeyBanner(
                    onTap: () => context.push(Routes.editProfile),
                  ),
                ],
                const SizedBox(height: 32),
                _IngredientInput(
                  controller: _controller,
                  onAdd: _addIngredient,
                ),
                const SizedBox(height: 16),
                if (ingredients.isNotEmpty) ...[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ingredients
                        .map((ing) => IngredientChip(
                              label: ing,
                              onRemove: () => ref
                                  .read(ingredientProvider.notifier)
                                  .remove(ing),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                _BentoStats(ingredientCount: ingredients.length),
                const SizedBox(height: 24),
                _SpinButton(
                  spinning: _spinning,
                  generating: _generating,
                  onPressed: _spin,
                ),
                const SizedBox(height: 32),
                Text(
                  'Tendances du moment',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: _TrendingList(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Trending list ────────────────────────────────────────────────────────────

class _TrendingList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trendingRecipesProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (recipes) {
        if (recipes.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final recipe = recipes[i];
              return TrendingCard(
                recipe: recipe,
                onTap: () {
                  // Build a RecipeMatch with no matched ingredients (browse mode).
                  final match = RecipeMatch(
                    recipe:             recipe,
                    matchScore:         0,
                    matchedIngredients: const [],
                    missingIngredients: recipe.ingredients,
                  );
                  context.push(Routes.result, extra: match);
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Private sub-widgets ────────────────────────────────────────────────────

class _MistralKeyBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _MistralKeyBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure ta clé API pour activer l\'app',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sans clé Mistral, la génération de recettes par IA ne fonctionne pas. Ajoute-la dans ton profil — c\'est gratuit et stocké sur ton téléphone.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aller au profil →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Qu'est-ce qu'il y a dans ton frigo ?",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Transforme tes restes en un plat savoureux.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          Positioned(
            right: -16,
            bottom: -20,
            child: Icon(
              Icons.restaurant,
              size: 100,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const _IngredientInput({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onAdd(),
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              hintText: 'Ajoute un ingrédient...',
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _BentoStats extends StatelessWidget {
  final int ingredientCount;
  const _BentoStats({required this.ingredientCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(ingredientCount * 25).clamp(0, 100)}%',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ANTIGASPILLAGE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                  ),
                  Text(
                    'Impact estimé',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 32),
                  const Spacer(),
                  Text(
                    'ÉCO-RESPONSABLE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                  ),
                  Text(
                    'Produits locaux',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpinButton extends StatelessWidget {
  final bool spinning;
  final bool generating;
  final VoidCallback onPressed;

  const _SpinButton({
    required this.spinning,
    required this.generating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final busy = spinning || generating;
    final label = generating
        ? 'L\'IA cuisine…'
        : spinning
            ? 'En cours...'
            : 'Trouver une recette';
    final icon = generating
        ? const Icon(Icons.auto_awesome, color: Colors.white)
        : const Icon(Icons.restaurant_menu, color: Colors.white);

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icon,
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
