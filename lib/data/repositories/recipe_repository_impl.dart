import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/firebase_recipe_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseRecipeSource _source;

  const RecipeRepositoryImpl(this._source);

  @override
  Future<List<Recipe>> getAll() => _source.getAll();

  @override
  Future<void> save(Recipe recipe) => _source.save(recipe);
}
