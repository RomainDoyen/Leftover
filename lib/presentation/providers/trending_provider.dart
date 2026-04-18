import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../domain/entities/recipe.dart';

/// Returns up to [_count] randomly picked recipes for the "Tendances" section.
const _count = 5;

final trendingRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final all = await ref.watch(recipeRepositoryProvider).getAll();
  if (all.isEmpty) return [];
  final shuffled = List<Recipe>.from(all)..shuffle(Random());
  return shuffled.take(_count).toList();
});
