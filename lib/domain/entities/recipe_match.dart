import 'package:equatable/equatable.dart';
import 'recipe.dart';
import 'ingredient.dart';

class RecipeMatch extends Equatable {
  final Recipe recipe;
  final double matchScore; // 0.0 → 1.0
  final List<Ingredient> matchedIngredients;
  final List<Ingredient> missingIngredients;

  const RecipeMatch({
    required this.recipe,
    required this.matchScore,
    required this.matchedIngredients,
    required this.missingIngredients,
  });

  /// Score as percentage (0 → 100), rounded.
  int get matchPercent => (matchScore * 100).round();

  @override
  List<Object?> get props => [recipe.id, matchScore];
}
