import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

/// Used when Firebase is not configured or for fast UI iteration.
class MockRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getAll() async => _recipes;

  @override
  Future<void> save(Recipe recipe) async {
    // No-op in mock mode — AI recipes are not persisted locally.
  }

  static const _recipes = [
    Recipe(
      id: 'quiche-lorraine',
      name: 'Quiche Lorraine',
      imageUrl: 'https://placehold.co/400x300/FF784E/FFFFFF?text=Quiche+Lorraine',
      cookTimeMinutes: 45,
      servingsMin: 2,
      servingsMax: 4,
      difficulty: 'intermédiaire',
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
      name: 'Poêlée Frigo Express',
      cookTimeMinutes: 20,
      servingsMin: 2,
      servingsMax: 3,
      difficulty: 'facile',
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
      name: 'Toast Umami Fondu',
      cookTimeMinutes: 15,
      servingsMin: 1,
      servingsMax: 2,
      difficulty: 'facile',
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
    Recipe(
      id: 'omelette',
      name: 'Omelette aux Herbes',
      cookTimeMinutes: 10,
      servingsMin: 1,
      servingsMax: 2,
      difficulty: 'facile',
      tags: ['french', 'quick', 'breakfast'],
      ingredients: [
        Ingredient(name: 'œufs', amount: '3', category: 'proteins', aliases: ['oeufs', 'oeuf', 'egg', 'eggs']),
        Ingredient(name: 'beurre', amount: '20g', category: 'dairy', aliases: ['butter']),
        Ingredient(name: 'ciboulette', amount: '1 bouquet', category: 'produce', aliases: ['chives', 'herbes', 'persil', 'herbs']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Battre les œufs', description: 'Casser les œufs dans un bol, saler, poivrer et fouetter vigoureusement.', durationMinutes: 2),
        RecipeStep(order: 2, title: 'Cuisson', description: 'Faire fondre le beurre à feu moyen. Verser les œufs. Remuer en pliant jusqu\'à prise.', durationMinutes: 4),
        RecipeStep(order: 3, title: 'Finition', description: 'Parsemer de ciboulette ciselée. Plier et servir immédiatement.', durationMinutes: 1),
      ],
    ),
    Recipe(
      id: 'soupe-tomate',
      name: 'Soupe Tomate Maison',
      cookTimeMinutes: 25,
      servingsMin: 2,
      servingsMax: 4,
      difficulty: 'facile',
      tags: ['french', 'soup', 'comfort'],
      ingredients: [
        Ingredient(name: 'tomates', amount: '4', category: 'produce', aliases: ['tomate', 'tomato', 'tomatoes']),
        Ingredient(name: 'oignon', amount: '1', category: 'produce', aliases: ['onion']),
        Ingredient(name: 'ail', amount: '2 gousses', category: 'produce', aliases: ['garlic']),
        Ingredient(name: 'bouillon', amount: '500ml', category: 'pantry', aliases: ['bouillon de légumes', 'broth', 'stock']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Faire revenir', description: 'Faire revenir oignon et ail émincés dans un filet d\'huile 3 min.', durationMinutes: 5),
        RecipeStep(order: 2, title: 'Mijoter', description: 'Ajouter les tomates en morceaux et le bouillon. Cuire à feu moyen 15 min.', durationMinutes: 15),
        RecipeStep(order: 3, title: 'Mixer', description: 'Mixer le tout jusqu\'à texture lisse. Rectifier l\'assaisonnement.', durationMinutes: 3),
      ],
    ),
    Recipe(
      id: 'pates-carbonara',
      name: 'Pâtes Carbonara Express',
      cookTimeMinutes: 20,
      servingsMin: 2,
      servingsMax: 3,
      difficulty: 'intermédiaire',
      tags: ['italian', 'pasta', 'quick'],
      ingredients: [
        Ingredient(name: 'pâtes', amount: '200g', category: 'pantry', aliases: ['spaghetti', 'pasta', 'tagliatelles', 'linguine']),
        Ingredient(name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon', 'pancetta', 'guanciale']),
        Ingredient(name: 'œufs', amount: '2', category: 'proteins', aliases: ['oeufs', 'oeuf', 'egg', 'eggs']),
        Ingredient(name: 'parmesan', amount: '50g', category: 'dairy', aliases: ['fromage', 'pecorino', 'cheese', 'fromage râpé']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Cuire les pâtes', description: 'Cuire les pâtes al dente dans de l\'eau bien salée. Réserver l\'eau de cuisson.', durationMinutes: 10),
        RecipeStep(order: 2, title: 'Lardons', description: 'Faire revenir les lardons à sec dans une poêle jusqu\'à légère dorure.', durationMinutes: 5),
        RecipeStep(order: 3, title: 'Mélange & service', description: 'Hors du feu, mélanger œufs battus + parmesan + pâtes + lardons. Ajouter un peu d\'eau de cuisson. Servir immédiatement.', durationMinutes: 3),
      ],
    ),
    Recipe(
      id: 'riz-saute',
      name: 'Riz Sauté aux Légumes',
      cookTimeMinutes: 15,
      servingsMin: 2,
      servingsMax: 3,
      difficulty: 'facile',
      tags: ['asian', 'quick', 'rice'],
      ingredients: [
        Ingredient(name: 'riz cuit', amount: '300g', category: 'pantry', aliases: ['riz', 'rice', 'riz blanc']),
        Ingredient(name: 'carottes', amount: '2', category: 'produce', aliases: ['carotte', 'carrot', 'carrots']),
        Ingredient(name: 'petits pois', amount: '100g', category: 'produce', aliases: ['peas', 'pois']),
        Ingredient(name: 'sauce soja', amount: '2 cuil.', category: 'pantry', aliases: ['soy sauce', 'shoyu']),
        Ingredient(name: 'œufs', amount: '2', category: 'proteins', aliases: ['oeufs', 'oeuf', 'egg', 'eggs']),
      ],
      steps: [
        RecipeStep(order: 1, title: 'Préparer les légumes', description: 'Couper les carottes en petits dés. Égoutter les petits pois.', durationMinutes: 3),
        RecipeStep(order: 2, title: 'Cuisson', description: 'Faire sauter les légumes 3 min à feu vif. Ajouter le riz froid et mélanger.', durationMinutes: 5),
        RecipeStep(order: 3, title: 'Finition', description: 'Pousser le riz sur le côté, brouiller les œufs. Incorporer au riz. Arroser de sauce soja.', durationMinutes: 4),
      ],
    ),
  ];
}
