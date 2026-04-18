import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Fetch all recipes from the data source.
  Future<List<Recipe>> getAll();

  /// Persist a recipe (used to save AI-generated recipes).
  Future<void> save(Recipe recipe);
}
