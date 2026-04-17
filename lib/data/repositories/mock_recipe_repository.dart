import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

/// Used when Firebase is not configured or for fast UI iteration.
class MockRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getAll() async => _recipes;

  static const _recipes = [
    Recipe(
      id: 'quiche-lorraine',
      name: 'Quiche Lorraine',
      cookTimeMinutes: 45,
      servingsMin: 2,
      servingsMax: 4,
      difficulty: 'intermediate',
      tags: ['french', 'savory', 'oven'],
      ingredients: [
        Ingredient(name: 'oignon', amount: '1 demi', category: 'produce', aliases: ['onion']),
        Ingredient(name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon', 'pancetta']),
        Ingredient(name: 'pâte à tarte', amount: '1', category: 'pastry', aliases: ['pie crust', 'shortcrust']),
        Ingredient(name: 'crème fraîche', amount: '200ml', category: 'dairy', aliases: ['cream', 'heavy cream']),
        Ingredient(name: 'fromage râpé', amount: '100g', category: 'dairy', aliases: ['cheese', 'gruyere', 'emmental', 'fromage frais', 'cream cheese']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Préchauffage & fond de tarte', description: 'Préchauffez le four à 200°C. Étalez la pâte dans un moule. Faites cuire à blanc 8 min.', durationMinutes: 10),
        RecipeStep(order: 2, title: 'La préparation', description: 'Battez 4 œufs avec la crème. Incorporez lardons et oignon émincé. Assaisonnez avec muscade.', durationMinutes: 10),
        RecipeStep(order: 3, title: 'Cuisson', description: "Versez dans le fond de tarte. Parsemez de fromage. Enfournez 15-18 min jusqu'à dorure.", durationMinutes: 18),
      ],
    ),
    Recipe(
      id: 'stir-fry',
      name: 'Kitchen Sink Stir-fry',
      cookTimeMinutes: 20,
      servingsMin: 2,
      servingsMax: 3,
      difficulty: 'easy',
      tags: ['asian', 'quick', 'wok'],
      ingredients: [
        Ingredient(name: 'sauce soja', amount: '3 cuil.', category: 'pantry', aliases: ['soy sauce', 'shoyu']),
        Ingredient(name: 'oignon', amount: '1', category: 'produce', aliases: ['onion']),
        Ingredient(name: 'ail', amount: '2 gousses', category: 'produce', aliases: ['garlic']),
        Ingredient(name: 'huile de sésame', amount: '1 cuil.', category: 'pantry', aliases: ['sesame oil']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Préparation', description: 'Émincer oignon et ail. Préparer la sauce soja avec une cuillère de sucre.', durationMinutes: 5),
        RecipeStep(order: 2, title: 'Cuisson wok', description: "Chauffer l'huile à feu vif. Faire revenir oignon 2 min, ajouter ail, puis sauce soja.", durationMinutes: 10),
        RecipeStep(order: 3, title: 'Service', description: 'Servir immédiatement sur riz blanc ou nouilles.', durationMinutes: 2),
      ],
    ),
    Recipe(
      id: 'cheesy-melt',
      name: 'Umami Leftover Melt',
      cookTimeMinutes: 15,
      servingsMin: 1,
      servingsMax: 2,
      difficulty: 'easy',
      tags: ['comfort', 'quick', 'toast'],
      ingredients: [
        Ingredient(name: 'fromage frais', amount: '100g', category: 'dairy', aliases: ['cream cheese', 'philadelphia', 'fromage', 'cheese']),
        Ingredient(name: 'sauce soja', amount: '2 cuil.', category: 'pantry', aliases: ['soy sauce']),
        Ingredient(name: 'pain', amount: '2 tranches', category: 'pantry', aliases: ['bread', 'toast']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Mélange', description: 'Mélanger fromage frais et sauce soja. Tartiner généreusement sur le pain.', durationMinutes: 3),
        RecipeStep(order: 2, title: 'Gratinage', description: "Passer au grill 5-7 min jusqu'à dorure. Servir chaud.", durationMinutes: 7),
      ],
    ),
  ];
}
