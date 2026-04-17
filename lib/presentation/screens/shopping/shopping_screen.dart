import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../presentation/providers/shopping_list_provider.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/shopping_item_tile.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Mes courses',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ref.read(shoppingRepositoryProvider).clearChecked();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Impossible de supprimer les éléments')),
                  );
                }
              }
            },
            child: const Text(
              'Effacer cochés',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Erreur : $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyState();
          }

          final unchecked = items.where((i) => !i.checked).toList();
          final checked = items.where((i) => i.checked).toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (unchecked.isNotEmpty) ...[
                Text(
                  'À ACHETER (${unchecked.length})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 12),
                ...unchecked.map((item) => ShoppingItemTile(
                      item: item,
                      onToggle: (v) => ref
                          .read(shoppingRepositoryProvider)
                          .toggleItem(item.id, v),
                    )),
              ],
              if (checked.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'DANS LE PANIER (${checked.length})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 12),
                ...checked.map((item) => ShoppingItemTile(
                      item: item,
                      onToggle: (v) => ref
                          .read(shoppingRepositoryProvider)
                          .toggleItem(item.id, v),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined,
                size: 72, color: AppColors.outlineVariant),
            SizedBox(height: 20),
            Text(
              'Ta liste est vide',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoute des ingrédients manquants\ndepuis la page Résultat',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
