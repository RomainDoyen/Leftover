// lib/presentation/providers/recipe_match_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/recipe_match.dart';
import '../../core/providers/repository_providers.dart';
import 'ingredient_provider.dart';

class RecipeMatchNotifier extends AsyncNotifier<List<RecipeMatch>> {
  static const _uuid = Uuid();

  @override
  Future<List<RecipeMatch>> build() async => [];

  /// Match user ingredients against the recipe database.
  Future<void> spin() async {
    final ingredients = ref.read(ingredientProvider);
    if (ingredients.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(matchRecipesUseCaseProvider).execute(ingredients),
    );
    await _saveTopMatchToHistory(ingredients, source: 'match');
  }

  /// Call Mistral AI to generate a recipe when no database match was found.
  /// Returns true if a recipe was successfully generated.
  Future<bool> generate() async {
    final ingredients = ref.read(ingredientProvider);
    if (ingredients.isEmpty) return false;

    final useCase = ref.read(generateRecipeUseCaseProvider);
    if (!useCase.isAvailable) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final match = await useCase.execute(ingredients);
      return [match];
    });

    await _saveTopMatchToHistory(ingredients, source: 'ai');
    return state.valueOrNull?.isNotEmpty ?? false;
  }

  Future<void> _saveTopMatchToHistory(
    List<String> ingredients, {
    required String source,
  }) async {
    final top = state.valueOrNull?.firstOrNull;
    if (top == null) return;
    try {
      final entry = HistoryEntry(
        id:              _uuid.v4(),
        match:           top,
        userIngredients: List.unmodifiable(ingredients),
        source:          source,
        createdAt:       DateTime.now(),
      );
      await ref.read(historyRepositoryProvider).saveEntry(entry);
    } catch (_) {
      // History save failure must not block the user experience.
    }
  }
}

final recipeMatchProvider =
    AsyncNotifierProvider<RecipeMatchNotifier, List<RecipeMatch>>(
        RecipeMatchNotifier.new);

/// The best match (top result), or null if no results.
final bestMatchProvider = Provider<RecipeMatch?>((ref) {
  return ref.watch(recipeMatchProvider).valueOrNull?.firstOrNull;
});
