import 'package:uuid/uuid.dart';
import '../entities/ingredient.dart';
import '../entities/recipe_match.dart';
import '../entities/shopping_item.dart';
import '../repositories/shopping_repository.dart';

class AddToShoppingListUseCase {
  final ShoppingRepository _repo;
  static const _uuid = Uuid();

  const AddToShoppingListUseCase(this._repo);

  Future<void> execute(Ingredient ingredient, RecipeMatch match) async {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: ingredient.name,
      category: ingredient.category,
      checked: false,
      recipeId: match.recipe.id,
      recipeName: match.recipe.name,
    );
    await _repo.addItem(item);
  }
}
