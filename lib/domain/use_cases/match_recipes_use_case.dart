import '../entities/recipe.dart';
import '../entities/recipe_match.dart';
import '../entities/ingredient.dart';
import '../repositories/recipe_repository.dart';
import '../../core/utils/string_normalizer.dart';

class MatchRecipesUseCase {
  final RecipeRepository _repo;

  const MatchRecipesUseCase(this._repo);

  Future<List<RecipeMatch>> execute(List<String> userIngredients) async {
    if (userIngredients.isEmpty) return [];
    final recipes = await _repo.getAll();
    return _score(recipes, userIngredients);
  }

  List<RecipeMatch> _score(List<Recipe> recipes, List<String> userIngredients) {
    final results = <RecipeMatch>[];

    for (final recipe in recipes) {
      final matched = <Ingredient>[];
      final missing = <Ingredient>[];

      for (final ing in recipe.ingredients) {
        final isMatch = fuzzyMatch(ing.name, userIngredients) ||
            ing.aliases.any((a) => fuzzyMatch(a, userIngredients));
        if (isMatch) {
          matched.add(ing);
        } else {
          missing.add(ing);
        }
      }

      final score = recipe.ingredients.isEmpty
          ? 0.0
          : matched.length / recipe.ingredients.length;

      if (matched.isNotEmpty) {
        results.add(RecipeMatch(
          recipe: recipe,
          matchScore: score,
          matchedIngredients: matched,
          missingIngredients: missing,
        ));
      }
    }

    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return results;
  }
}
