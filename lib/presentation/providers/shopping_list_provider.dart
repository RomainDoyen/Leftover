// lib/presentation/providers/shopping_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../domain/entities/shopping_item.dart';

final shoppingListProvider = StreamProvider<List<ShoppingItem>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchItems();
});

/// Count of unchecked items (for bottom nav badge).
final shoppingBadgeProvider = Provider<int>((ref) {
  return ref.watch(shoppingListProvider).valueOrNull
      ?.where((i) => !i.checked)
      .length ?? 0;
});
