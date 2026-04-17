import '../../core/utils/string_normalizer.dart';
import '../../data/datasources/mistral_recipe_source.dart';
import '../entities/recipe_match.dart';

/// Generates a recipe via Mistral AI and wraps it as a [RecipeMatch].
class GenerateRecipeUseCase {
  final MistralRecipeSource _source;

  const GenerateRecipeUseCase(this._source);

  bool get isAvailable => _source.isAvailable;

  Future<RecipeMatch> execute(List<String> userIngredients) async {
    final recipe = await _source.generateFromIngredients(userIngredients);

    // Score the AI recipe against the user's ingredients.
    final matched = recipe.ingredients
        .where((ing) =>
            fuzzyMatch(ing.name, userIngredients) ||
            ing.aliases.any((a) => fuzzyMatch(a, userIngredients)))
        .toList();
    final missing = recipe.ingredients
        .where((ing) => !matched.contains(ing))
        .toList();
    final score = recipe.ingredients.isEmpty
        ? 0.0
        : matched.length / recipe.ingredients.length;

    return RecipeMatch(
      recipe:               recipe,
      matchScore:           score,
      matchedIngredients:   matched,
      missingIngredients:   missing,
    );
  }
}
