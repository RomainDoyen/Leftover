import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Fetch all recipes from the data source.
  Future<List<Recipe>> getAll();
}
