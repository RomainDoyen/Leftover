import 'package:equatable/equatable.dart';
import 'ingredient.dart';

class RecipeStep {
  final int order;
  final String title;
  final String description;
  final int durationMinutes;

  const RecipeStep({
    required this.order,
    required this.title,
    required this.description,
    required this.durationMinutes,
  });
}

class Recipe extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int cookTimeMinutes;
  final int servingsMin;
  final int servingsMax;
  final String difficulty; // easy | intermediate | hard
  final List<String> tags;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;

  const Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.cookTimeMinutes,
    required this.servingsMin,
    required this.servingsMax,
    required this.difficulty,
    required this.tags,
    required this.ingredients,
    required this.steps,
  });

  @override
  List<Object?> get props => [id, name];
}
