// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/ingredient_provider.dart';
import '../../../presentation/providers/recipe_match_provider.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/ingredient_chip.dart';
import 'widgets/trending_card.dart';

const _useFirebase = bool.fromEnvironment('USE_FIREBASE');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  bool _spinning = false;

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
    setState(() => _spinning = true);
    await ref.read(recipeMatchProvider.notifier).spin();

    if (!mounted) return;
    setState(() => _spinning = false);
    final match = ref.read(bestMatchProvider);
    if (match != null) {
      context.push(Routes.result, extra: match);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune recette trouvée. Essaie d\'autres ingrédients !'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientProvider);

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
                  'Leftover Roulette',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            actions: [
              if (_useFirebase)
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: AppColors.primary,
                  tooltip: 'Se déconnecter',
                  onPressed: () async {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signOut();
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  color: AppColors.primary,
                  onPressed: () {},
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _HeroCard(),
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
                _SpinButton(spinning: _spinning, onPressed: _spin),
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
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: const [
                  TrendingCard(
                    title: 'Poêlée Frigo Express',
                    subtitle: 'Rapide · 20 min · Facile',
                  ),
                  SizedBox(width: 16),
                  TrendingCard(
                    title: 'Toast Umami Fondu',
                    subtitle: 'Réconfort · 15 min · Facile',
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Private sub-widgets ────────────────────────────────────────────────────

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
                "Qu'est-ce qu'il y a\ndans ton frigo ?",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.onSurface,
                      height: 1.1,
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
  final VoidCallback onPressed;

  const _SpinButton({required this.spinning, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: spinning ? null : onPressed,
        icon: spinning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.casino, color: Colors.white),
        label: Text(
          spinning ? 'En cours...' : 'Lancer la roulette',
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
