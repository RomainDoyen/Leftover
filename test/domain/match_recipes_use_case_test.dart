import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:leftover_roulette/domain/entities/ingredient.dart';
import 'package:leftover_roulette/domain/entities/recipe.dart';
import 'package:leftover_roulette/domain/repositories/recipe_repository.dart';
import 'package:leftover_roulette/domain/use_cases/match_recipes_use_case.dart';

@GenerateMocks([RecipeRepository])
import 'match_recipes_use_case_test.mocks.dart';

void main() {
  late MockRecipeRepository mockRepo;
  late MatchRecipesUseCase useCase;

  const quicheRecipe = Recipe(
    id: 'quiche-1',
    name: 'Quiche Lorraine',
    cookTimeMinutes: 45,
    servingsMin: 2,
    servingsMax: 4,
    difficulty: 'intermediate',
    tags: [],
    ingredients: [
      Ingredient(name: 'oignon', amount: '1', category: 'produce'),
      Ingredient(
          name: 'lardons',
          amount: '150g',
          category: 'proteins',
          aliases: ['bacon']),
      Ingredient(name: 'pâte à tarte', amount: '1', category: 'pastry'),
      Ingredient(name: 'crème fraîche', amount: '200ml', category: 'dairy'),
    ],
    steps: [],
  );

  setUp(() {
    mockRepo = MockRecipeRepository();
    useCase = MatchRecipesUseCase(mockRepo);
    when(mockRepo.getAll()).thenAnswer((_) async => [quicheRecipe]);
  });

  test('returns empty list when no ingredients provided', () async {
    final result = await useCase.execute([]);
    expect(result, isEmpty);
    verifyNever(mockRepo.getAll());
  });

  test('calculates correct match score', () async {
    final result = await useCase.execute(['oignon', 'bacon']);
    expect(result, hasLength(1));
    expect(result.first.matchScore, closeTo(0.5, 0.01)); // 2/4
    expect(result.first.matchPercent, 50);
  });

  test('matched and missing ingredients are correctly partitioned', () async {
    final result = await useCase.execute(['oignon', 'bacon']);
    expect(result.first.matchedIngredients.map((i) => i.name),
        containsAll(['oignon', 'lardons']));
    expect(result.first.missingIngredients.map((i) => i.name),
        containsAll(['pâte à tarte', 'crème fraîche']));
  });

  test('excludes recipes below 30% threshold', () async {
    final result = await useCase.execute(['sel']);
    expect(result, isEmpty);
  });

  test('matches via alias', () async {
    // 3-ingredient recipe so alias match gives 1/3 = 33% >= 30% threshold
    const quiche3 = Recipe(
      id: 'quiche-1',
      name: 'Quiche Lorraine',
      cookTimeMinutes: 45,
      servingsMin: 2,
      servingsMax: 4,
      difficulty: 'intermediate',
      tags: [],
      ingredients: [
        Ingredient(
            name: 'lardons',
            amount: '150g',
            category: 'proteins',
            aliases: ['bacon']),
        Ingredient(name: 'pâte à tarte', amount: '1', category: 'pastry'),
        Ingredient(name: 'crème fraîche', amount: '200ml', category: 'dairy'),
      ],
      steps: [],
    );
    when(mockRepo.getAll()).thenAnswer((_) async => [quiche3]);
    final result = await useCase.execute(['bacon']);
    expect(result, hasLength(1));
    expect(result.first.matchedIngredients.map((i) => i.name),
        contains('lardons'));
  });

  test('sorts results by score descending', () async {
    const omelette = Recipe(
      id: 'omelette-1',
      name: 'Omelette',
      cookTimeMinutes: 10,
      servingsMin: 1,
      servingsMax: 2,
      difficulty: 'easy',
      tags: [],
      ingredients: [
        Ingredient(name: 'oignon', amount: '0.5', category: 'produce')
      ],
      steps: [],
    );
    when(mockRepo.getAll()).thenAnswer((_) async => [quicheRecipe, omelette]);
    final result = await useCase.execute(['oignon']);
    // omelette = 1/1 = 100%, quiche = 1/4 = 25% (excluded < 30%)
    expect(result.length, 1);
    expect(result.first.recipe.name, 'Omelette');
  });
}
