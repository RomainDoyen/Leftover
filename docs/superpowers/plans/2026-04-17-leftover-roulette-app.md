# Leftover Roulette — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construire l'app mobile Flutter Leftover Roulette (Android + iOS) avec Firebase — saisie d'ingrédients, matching de recettes, liste de courses synchronisée, et mode cuisine pas-à-pas.

**Architecture:** Clean Architecture 3 couches (domain / data / presentation), Riverpod pour le state management, GoRouter pour la navigation. Les recettes vivent dans Firestore. L'app fonctionne en mode mock (données hardcodées) jusqu'à ce que Firebase soit configuré — les deux sont activés en parallèle dès le début.

**Tech Stack:** Flutter ≥ 3.19, Dart ≥ 3.3, firebase_core ^2.24, cloud_firestore ^4.13, firebase_auth ^4.15, flutter_riverpod ^2.5, go_router ^13, google_sign_in ^6.2, cached_network_image ^3.3, freezed ^2.4, json_annotation ^6.7, build_runner ^2.4

---

## Arborescence cible

```
leftover-roulette/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart          # généré par flutterfire
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   └── app_strings.dart
│   │   ├── errors/failures.dart
│   │   ├── router/app_router.dart
│   │   └── utils/string_normalizer.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── firebase_recipe_source.dart
│   │   │   └── firebase_shopping_source.dart
│   │   ├── models/
│   │   │   ├── recipe_model.dart
│   │   │   ├── ingredient_model.dart
│   │   │   └── shopping_item_model.dart
│   │   └── repositories/
│   │       ├── recipe_repository_impl.dart
│   │       └── shopping_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── recipe.dart
│   │   │   ├── ingredient.dart
│   │   │   ├── recipe_match.dart
│   │   │   └── shopping_item.dart
│   │   ├── repositories/
│   │   │   ├── recipe_repository.dart
│   │   │   └── shopping_repository.dart
│   │   └── use_cases/
│   │       ├── match_recipes_use_case.dart
│   │       └── add_to_shopping_list_use_case.dart
│   └── presentation/
│       ├── providers/
│       │   ├── ingredient_provider.dart
│       │   ├── recipe_match_provider.dart
│       │   └── shopping_list_provider.dart
│       ├── screens/
│       │   ├── home/
│       │   │   ├── home_screen.dart
│       │   │   └── widgets/
│       │   │       ├── ingredient_chip.dart
│       │   │       └── trending_card.dart
│       │   ├── result/
│       │   │   ├── result_screen.dart
│       │   │   └── widgets/
│       │   │       ├── match_ring.dart
│       │   │       └── ingredient_list_item.dart
│       │   ├── shopping/
│       │   │   ├── shopping_screen.dart
│       │   │   └── widgets/shopping_item_tile.dart
│       │   └── cooking/
│       │       ├── cooking_screen.dart
│       │       └── widgets/
│       │           ├── recipe_step_card.dart
│       │           └── cooking_timer.dart
│       └── theme/
│           ├── app_theme.dart
│           └── app_colors.dart
├── test/
│   ├── domain/
│   │   └── match_recipes_use_case_test.dart
│   └── presentation/
│       └── home_screen_test.dart
├── scripts/
│   ├── package.json
│   └── seed_firestore.js
└── pubspec.yaml
```

---

## Task 1 — Scaffold du projet Flutter

**Files:**
- Create: `leftover-roulette/pubspec.yaml`
- Create: `leftover-roulette/lib/main.dart`

- [ ] **Étape 1 : Créer le projet Flutter**

```bash
cd /home/romain/Documents/Projets
flutter create --org com.leftover --platforms android,ios leftover-roulette
cd leftover-roulette
```

- [ ] **Étape 2 : Remplacer pubspec.yaml**

```yaml
name: leftover_roulette
description: Turn your fridge leftovers into real recipes.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.6
  firebase_auth: ^4.15.3

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^13.2.0

  # Auth
  google_sign_in: ^6.2.1

  # UI
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10+1

  # Utils
  shared_preferences: ^2.2.3
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  mockito: ^5.4.4

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

- [ ] **Étape 3 : Créer les dossiers d'assets**

```bash
mkdir -p assets/images assets/icons
touch assets/images/.gitkeep assets/icons/.gitkeep
```

- [ ] **Étape 4 : Installer les dépendances**

```bash
flutter pub get
```

Expected : `Got dependencies!` — aucune erreur.

- [ ] **Étape 5 : Commit initial**

```bash
git init
git add .
git commit -m "feat: flutter project scaffold"
```

---

## Task 2 — Thème & couleurs

**Files:**
- Create: `lib/presentation/theme/app_colors.dart`
- Create: `lib/presentation/theme/app_theme.dart`
- Modify: `lib/main.dart`

- [ ] **Étape 1 : Créer app_colors.dart**

```dart
// lib/presentation/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary           = Color(0xFFA83206);
  static const primaryContainer  = Color(0xFFFF784E);
  static const secondary         = Color(0xFF0C6A24);
  static const secondaryContainer= Color(0xFF9FF79F);
  static const tertiary          = Color(0xFF843D99);
  static const surface           = Color(0xFFF7F7F2);
  static const surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const surfaceContainerLow     = Color(0xFFF1F1EC);
  static const surfaceContainer        = Color(0xFFE8E9E3);
  static const surfaceContainerHigh    = Color(0xFFE2E3DD);
  static const surfaceContainerHighest = Color(0xFFDCDDD7);
  static const onSurface         = Color(0xFF2D2F2C);
  static const onSurfaceVariant  = Color(0xFF5A5C58);
  static const outline           = Color(0xFF767773);
  static const outlineVariant    = Color(0xFFADADA9);
  static const error             = Color(0xFFB31B25);
  static const onPrimary         = Color(0xFFFFEFEB);
  static const onSecondary       = Color(0xFFD0FFCB);
  static const onSecondaryContainer = Color(0xFF005F1D);
}
```

- [ ] **Étape 2 : Créer app_theme.dart**

```dart
// lib/presentation/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary:          AppColors.primary,
      onPrimary:        AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: Color(0xFF470E00),
      secondary:        AppColors.secondary,
      onSecondary:      AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary:         AppColors.tertiary,
      onTertiary:       Color(0xFFFFEDFD),
      error:            AppColors.error,
      onError:          Color(0xFFFFEFEE),
      surface:          AppColors.surface,
      onSurface:        AppColors.onSurface,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 40),
      displayMedium:  TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 32),
      headlineLarge:  TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700, fontSize: 28),
      headlineMedium: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700, fontSize: 22),
      headlineSmall:  TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700, fontSize: 18),
      bodyLarge:      TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 16),
      bodyMedium:     TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 14),
      labelLarge:     TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
      labelMedium:    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12),
      labelSmall:     TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 10),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.9),
      indicatorColor: const Color(0xFFFFE8DF),
    ),
  );
}
```

> **Note :** Pour utiliser les polices Google (PlusJakartaSans, Inter), ajouter les assets localement ou utiliser le package `google_fonts`. Pour l'instant, Flutter utilisera la police système. On ajoutera `google_fonts: ^6.1.0` au pubspec à cette étape.

- [ ] **Étape 3 : Ajouter google_fonts au pubspec.yaml**

Ajouter sous `dependencies:` :
```yaml
  google_fonts: ^6.1.0
```

Puis `flutter pub get`.

- [ ] **Étape 4 : Mettre à jour app_theme.dart pour google_fonts**

Remplacer les `TextStyle(fontFamily: 'Inter', ...)` par :

```dart
// lib/presentation/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:          AppColors.primary,
        onPrimary:        AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Color(0xFF470E00),
        secondary:        AppColors.secondary,
        onSecondary:      AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary:         AppColors.tertiary,
        onTertiary:       Color(0xFFFFEDFD),
        error:            AppColors.error,
        onError:          Color(0xFFFFEFEE),
        surface:          AppColors.surface,
        onSurface:        AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge:   GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 40),
        displayMedium:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 32),
        headlineLarge:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 22),
        headlineSmall:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
    );
  }
}
```

- [ ] **Étape 5 : Écrire main.dart minimal**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init — décommenté après Task 3
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: LeftoverRouletteApp()));
}

class LeftoverRouletteApp extends ConsumerWidget {
  const LeftoverRouletteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Leftover Roulette',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Étape 6 : Vérifier que l'app compile**

```bash
flutter run --debug
```

Expected : app blanche (router pas encore configuré), aucune erreur de compilation.

- [ ] **Étape 7 : Commit**

```bash
git add .
git commit -m "feat: app theme, colors, main entry point"
```

---

## Task 3 — Firebase Setup

**Files:**
- Create: `lib/firebase_options.dart` (généré automatiquement)

> **Étape manuelle obligatoire (faite par le dev, pas l'agent) :**
> 1. Créer un projet Firebase sur https://console.firebase.google.com
> 2. Activer **Cloud Firestore** (mode test au départ)
> 3. Activer **Firebase Authentication** (Email/Password + Google)
> 4. Nommer le projet : `leftover-roulette`

- [ ] **Étape 1 : Installer FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
```

- [ ] **Étape 2 : Configurer Firebase**

```bash
flutterfire configure --project=leftover-roulette
```

Sélectionner : Android + iOS. Cela génère `lib/firebase_options.dart`.

- [ ] **Étape 3 : Activer Firebase dans main.dart**

Décommenter dans `lib/main.dart` :

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: LeftoverRouletteApp()));
}
```

- [ ] **Étape 4 : Vérifier la connexion Firebase**

```bash
flutter run --debug
```

Expected : pas d'erreur Firebase au lancement. Vérifier dans les logs : `[firebase_core] Initialized`.

- [ ] **Étape 5 : Commit**

```bash
git add .
git commit -m "feat: firebase initialization"
```

---

## Task 4 — Domain Layer : Entities

**Files:**
- Create: `lib/domain/entities/ingredient.dart`
- Create: `lib/domain/entities/recipe.dart`
- Create: `lib/domain/entities/recipe_match.dart`
- Create: `lib/domain/entities/shopping_item.dart`

- [ ] **Étape 1 : ingredient.dart**

```dart
// lib/domain/entities/ingredient.dart
import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String amount;
  final String category; // proteins | dairy | produce | pantry | pastry
  final List<String> aliases;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.category,
    this.aliases = const [],
  });

  @override
  List<Object?> get props => [name, amount, category, aliases];
}
```

- [ ] **Étape 2 : recipe.dart**

```dart
// lib/domain/entities/recipe.dart
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
```

- [ ] **Étape 3 : recipe_match.dart**

```dart
// lib/domain/entities/recipe_match.dart
import 'package:equatable/equatable.dart';
import 'recipe.dart';
import 'ingredient.dart';

class RecipeMatch extends Equatable {
  final Recipe recipe;
  final double matchScore;           // 0.0 → 1.0
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
```

- [ ] **Étape 4 : shopping_item.dart**

```dart
// lib/domain/entities/shopping_item.dart
import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final bool checked;
  final String? recipeId;
  final String? recipeName;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.checked,
    this.recipeId,
    this.recipeName,
  });

  ShoppingItem copyWith({bool? checked}) =>
      ShoppingItem(
        id: id,
        name: name,
        category: category,
        checked: checked ?? this.checked,
        recipeId: recipeId,
        recipeName: recipeName,
      );

  @override
  List<Object?> get props => [id, name, checked];
}
```

- [ ] **Étape 5 : Commit**

```bash
git add lib/domain/
git commit -m "feat: domain entities (ingredient, recipe, recipe_match, shopping_item)"
```

---

## Task 5 — Domain Layer : Use Cases

**Files:**
- Create: `lib/core/utils/string_normalizer.dart`
- Create: `lib/domain/repositories/recipe_repository.dart`
- Create: `lib/domain/repositories/shopping_repository.dart`
- Create: `lib/domain/use_cases/match_recipes_use_case.dart`
- Create: `lib/domain/use_cases/add_to_shopping_list_use_case.dart`
- Create: `test/domain/match_recipes_use_case_test.dart`

- [ ] **Étape 1 : string_normalizer.dart**

```dart
// lib/core/utils/string_normalizer.dart

/// Normalize a string for fuzzy matching: lowercase, trim, remove accents.
String normalize(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

/// Returns true if [ingredient] matches any of [userIngredients] via fuzzy comparison.
bool fuzzyMatch(String ingredient, List<String> userIngredients) {
  final norm = normalize(ingredient);
  return userIngredients.any((u) {
    final un = normalize(u);
    return norm.contains(un) || un.contains(norm);
  });
}
```

- [ ] **Étape 2 : recipe_repository.dart (interface)**

```dart
// lib/domain/repositories/recipe_repository.dart
import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Fetch all recipes from the data source.
  Future<List<Recipe>> getAll();
}
```

- [ ] **Étape 3 : shopping_repository.dart (interface)**

```dart
// lib/domain/repositories/shopping_repository.dart
import '../entities/shopping_item.dart';

abstract class ShoppingRepository {
  /// Stream of shopping items for the current user.
  Stream<List<ShoppingItem>> watchItems();

  /// Add an item to the shopping list.
  Future<void> addItem(ShoppingItem item);

  /// Toggle checked state of an item.
  Future<void> toggleItem(String itemId, bool checked);

  /// Remove all checked items.
  Future<void> clearChecked();
}
```

- [ ] **Étape 4 : match_recipes_use_case.dart**

```dart
// lib/domain/use_cases/match_recipes_use_case.dart
import '../entities/recipe.dart';
import '../entities/recipe_match.dart';
import '../entities/ingredient.dart';
import '../repositories/recipe_repository.dart';
import '../../core/utils/string_normalizer.dart';

class MatchRecipesUseCase {
  final RecipeRepository _repo;
  static const double _minScore = 0.30;

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

      if (score >= _minScore) {
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
```

- [ ] **Étape 5 : add_to_shopping_list_use_case.dart**

```dart
// lib/domain/use_cases/add_to_shopping_list_use_case.dart
import 'package:uuid/uuid.dart';
import '../entities/ingredient.dart';
import '../entities/shopping_item.dart';
import '../entities/recipe_match.dart';
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
```

> **Note :** Ajouter `uuid: ^4.3.3` au pubspec.yaml, puis `flutter pub get`.

- [ ] **Étape 6 : Écrire le test unitaire**

```dart
// test/domain/match_recipes_use_case_test.dart
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

  final quicheRecipe = Recipe(
    id: 'quiche-1',
    name: 'Quiche Lorraine',
    cookTimeMinutes: 45,
    servingsMin: 2,
    servingsMax: 4,
    difficulty: 'intermediate',
    tags: [],
    ingredients: [
      Ingredient(name: 'oignon', amount: '1', category: 'produce'),
      Ingredient(name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon']),
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
  });

  test('calculates correct match score', () async {
    final result = await useCase.execute(['oignon', 'bacon']);
    expect(result, hasLength(1));
    expect(result.first.matchScore, closeTo(0.5, 0.01)); // 2/4
    expect(result.first.matchPercent, 50);
  });

  test('excludes recipes below 30% threshold', () async {
    final result = await useCase.execute(['sel']);
    expect(result, isEmpty);
  });

  test('sorts results by score descending', () async {
    final simpleRecipe = Recipe(
      id: 'omelette-1',
      name: 'Omelette',
      cookTimeMinutes: 10,
      servingsMin: 1,
      servingsMax: 2,
      difficulty: 'easy',
      tags: [],
      ingredients: [Ingredient(name: 'oignon', amount: '0.5', category: 'produce')],
      steps: [],
    );
    when(mockRepo.getAll()).thenAnswer((_) async => [quicheRecipe, simpleRecipe]);
    final result = await useCase.execute(['oignon']);
    // omelette = 1/1 = 100%, quiche = 1/4 = 25% (excluded)
    expect(result.first.recipe.name, 'Omelette');
  });
}
```

- [ ] **Étape 7 : Générer les mocks**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Étape 8 : Lancer les tests**

```bash
flutter test test/domain/match_recipes_use_case_test.dart -v
```

Expected : 4 tests passent.

- [ ] **Étape 9 : Commit**

```bash
git add .
git commit -m "feat: domain use cases + tests (matching algorithm)"
```

---

## Task 6 — Data Layer : Mock Repository + Firebase

**Files:**
- Create: `lib/data/repositories/mock_recipe_repository.dart`
- Create: `lib/data/datasources/firebase_recipe_source.dart`
- Create: `lib/data/repositories/recipe_repository_impl.dart`
- Create: `lib/data/repositories/shopping_repository_impl.dart`

- [ ] **Étape 1 : mock_recipe_repository.dart (données hardcodées)**

```dart
// lib/data/repositories/mock_recipe_repository.dart
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

/// Used when Firebase is not configured or for fast UI iteration.
class MockRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getAll() async => _recipes;

  static final _recipes = [
    Recipe(
      id: 'quiche-lorraine',
      name: 'Quiche Lorraine',
      imageUrl: null,
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
        RecipeStep(order: 3, title: 'Cuisson', description: 'Versez dans le fond de tarte. Parsemez de fromage. Enfournez 15-18 min jusqu\'à dorure.', durationMinutes: 18),
      ],
    ),
    Recipe(
      id: 'stir-fry',
      name: 'Kitchen Sink Stir-fry',
      imageUrl: null,
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
        RecipeStep(order: 2, title: 'Cuisson wok', description: 'Chauffer l\'huile à feu vif. Faire revenir oignon 2 min, ajouter ail, puis sauce soja.', durationMinutes: 10),
        RecipeStep(order: 3, title: 'Service', description: 'Servir immédiatement sur riz blanc ou nouilles.', durationMinutes: 2),
      ],
    ),
    Recipe(
      id: 'cheesy-melt',
      name: 'Umami Leftover Melt',
      imageUrl: null,
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
        RecipeStep(order: 2, title: 'Gratinage', description: 'Passer au grill 5-7 min jusqu\'à dorure. Servir chaud.', durationMinutes: 7),
      ],
    ),
  ];
}
```

- [ ] **Étape 2 : firebase_recipe_source.dart**

```dart
// lib/data/datasources/firebase_recipe_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';

class FirebaseRecipeSource {
  final FirebaseFirestore _db;

  FirebaseRecipeSource(this._db);

  Future<List<Recipe>> getAll() async {
    final snapshot = await _db.collection('recipes').get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  Recipe _fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String?,
      cookTimeMinutes: (data['cookTimeMinutes'] as num).toInt(),
      servingsMin: (data['servings']?['min'] as num? ?? 2).toInt(),
      servingsMax: (data['servings']?['max'] as num? ?? 4).toInt(),
      difficulty: data['difficulty'] as String? ?? 'easy',
      tags: List<String>.from(data['tags'] ?? []),
      ingredients: (data['ingredients'] as List<dynamic>? ?? [])
          .map((i) => Ingredient(
                name: i['name'] as String,
                amount: i['amount'] as String? ?? '',
                category: i['category'] as String? ?? 'pantry',
                aliases: List<String>.from(i['aliases'] ?? []),
              ))
          .toList(),
      steps: (data['steps'] as List<dynamic>? ?? [])
          .map((s) => RecipeStep(
                order: (s['order'] as num).toInt(),
                title: s['title'] as String,
                description: s['description'] as String,
                durationMinutes: (s['durationMinutes'] as num? ?? 5).toInt(),
              ))
          .toList(),
    );
  }
}
```

- [ ] **Étape 3 : recipe_repository_impl.dart**

```dart
// lib/data/repositories/recipe_repository_impl.dart
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/firebase_recipe_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseRecipeSource _source;

  const RecipeRepositoryImpl(this._source);

  @override
  Future<List<Recipe>> getAll() => _source.getAll();
}
```

- [ ] **Étape 4 : shopping_repository_impl.dart**

```dart
// lib/data/repositories/shopping_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ShoppingRepositoryImpl(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _col => _db
      .collection('users')
      .doc(_uid ?? 'anonymous')
      .collection('shoppingLists')
      .doc('current')
      .collection('items');

  @override
  Stream<List<ShoppingItem>> watchItems() {
    return _col.orderBy('addedAt').snapshots().map((s) =>
        s.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> addItem(ShoppingItem item) async {
    await _col.doc(item.id).set({
      'name': item.name,
      'category': item.category,
      'checked': item.checked,
      'recipeId': item.recipeId,
      'recipeName': item.recipeName,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleItem(String itemId, bool checked) async {
    await _col.doc(itemId).update({'checked': checked});
  }

  @override
  Future<void> clearChecked() async {
    final checked = await _col.where('checked', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in checked.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  ShoppingItem _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      name: data['name'] as String,
      category: data['category'] as String? ?? 'pantry',
      checked: data['checked'] as bool? ?? false,
      recipeId: data['recipeId'] as String?,
      recipeName: data['recipeName'] as String?,
    );
  }
}
```

- [ ] **Étape 5 : Commit**

```bash
git add .
git commit -m "feat: data layer (mock + firebase repositories)"
```

---

## Task 7 — Providers Riverpod

**Files:**
- Create: `lib/presentation/providers/ingredient_provider.dart`
- Create: `lib/presentation/providers/recipe_match_provider.dart`
- Create: `lib/presentation/providers/shopping_list_provider.dart`
- Create: `lib/core/providers/repository_providers.dart`

- [ ] **Étape 1 : repository_providers.dart**

```dart
// lib/core/providers/repository_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_recipe_source.dart';
import '../../data/repositories/mock_recipe_repository.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/shopping_repository_impl.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../domain/use_cases/add_to_shopping_list_use_case.dart';
import '../../domain/use_cases/match_recipes_use_case.dart';

// Set to true to use real Firebase, false for mock data
const _useFirebase = false;

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  if (_useFirebase) {
    return RecipeRepositoryImpl(
      FirebaseRecipeSource(FirebaseFirestore.instance),
    );
  }
  return MockRecipeRepository();
});

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final matchRecipesUseCaseProvider = Provider<MatchRecipesUseCase>((ref) {
  return MatchRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final addToShoppingListUseCaseProvider = Provider<AddToShoppingListUseCase>((ref) {
  return AddToShoppingListUseCase(ref.watch(shoppingRepositoryProvider));
});
```

- [ ] **Étape 2 : ingredient_provider.dart**

```dart
// lib/presentation/providers/ingredient_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IngredientNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty || state.contains(trimmed.toLowerCase())) return;
    state = [...state, trimmed.toLowerCase()];
  }

  void remove(String ingredient) {
    state = state.where((i) => i != ingredient).toList();
  }

  void clear() => state = [];
}

final ingredientProvider =
    NotifierProvider<IngredientNotifier, List<String>>(IngredientNotifier.new);
```

- [ ] **Étape 3 : recipe_match_provider.dart**

```dart
// lib/presentation/providers/recipe_match_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe_match.dart';
import '../../core/providers/repository_providers.dart';
import 'ingredient_provider.dart';

/// AsyncNotifier that runs matching when triggered.
class RecipeMatchNotifier extends AsyncNotifier<List<RecipeMatch>> {
  @override
  Future<List<RecipeMatch>> build() async => [];

  Future<void> spin() async {
    final ingredients = ref.read(ingredientProvider);
    if (ingredients.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(matchRecipesUseCaseProvider).execute(ingredients));
  }
}

final recipeMatchProvider =
    AsyncNotifierProvider<RecipeMatchNotifier, List<RecipeMatch>>(
        RecipeMatchNotifier.new);

/// The best match (first result).
final bestMatchProvider = Provider<RecipeMatch?>((ref) {
  return ref.watch(recipeMatchProvider).valueOrNull?.firstOrNull;
});
```

- [ ] **Étape 4 : shopping_list_provider.dart**

```dart
// lib/presentation/providers/shopping_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../domain/entities/shopping_item.dart';

final shoppingListProvider = StreamProvider<List<ShoppingItem>>((ref) {
  return ref.watch(shoppingRepositoryProvider).watchItems();
});

/// Count of unchecked items (for badge).
final shoppingBadgeProvider = Provider<int>((ref) {
  return ref.watch(shoppingListProvider).valueOrNull
      ?.where((i) => !i.checked)
      .length ?? 0;
});
```

- [ ] **Étape 5 : Commit**

```bash
git add .
git commit -m "feat: riverpod providers (ingredients, matching, shopping)"
```

---

## Task 8 — Navigation GoRouter

**Files:**
- Create: `lib/core/router/app_router.dart`

- [ ] **Étape 1 : app_router.dart**

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/recipe_match.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/result/result_screen.dart';
import '../../presentation/screens/shopping/shopping_screen.dart';
import '../../presentation/screens/cooking/cooking_screen.dart';

// Route path constants
abstract class Routes {
  static const home     = '/';
  static const result   = '/result';
  static const shopping = '/shopping';
  static const cooking  = '/cooking';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.shopping,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShoppingScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.result,
        builder: (context, state) {
          final match = state.extra as RecipeMatch?;
          return ResultScreen(match: match);
        },
      ),
      GoRoute(
        path: Routes.cooking,
        builder: (context, state) {
          final match = state.extra as RecipeMatch?;
          return CookingScreen(match: match);
        },
      ),
    ],
  );
});

/// Bottom navigation shell wrapping Home + Shopping tabs.
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(currentLocation: location),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String currentLocation;
  const _BottomNav({required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.casino_outlined, filledIcon: Icons.casino, label: 'Spin',     path: Routes.home),
      (icon: Icons.bookmark_outline, filledIcon: Icons.bookmark, label: 'Saved', path: '/saved'),
      (icon: Icons.shopping_basket_outlined, filledIcon: Icons.shopping_basket,  label: 'Shopping', path: Routes.shopping),
    ];

    return NavigationBar(
      selectedIndex: _selectedIndex(currentLocation, items.map((i) => i.path).toList()),
      onDestinationSelected: (i) => context.go(items[i].path),
      destinations: items.map((item) {
        final selected = currentLocation == item.path;
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.filledIcon),
          label: item.label,
        );
      }).toList(),
    );
  }

  int _selectedIndex(String loc, List<String> paths) {
    final idx = paths.indexOf(loc);
    return idx < 0 ? 0 : idx;
  }
}
```

- [ ] **Étape 2 : Créer des écrans placeholder**

```dart
// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}
```

Répéter pour `result_screen.dart`, `shopping_screen.dart`, `cooking_screen.dart` (même contenu, class name adapté).

- [ ] **Étape 3 : Vérifier la navigation**

```bash
flutter run
```

Expected : bottom nav avec 3 onglets, navigation entre Home et Shopping fonctionne.

- [ ] **Étape 4 : Commit**

```bash
git add .
git commit -m "feat: gorouter navigation + bottom nav shell"
```

---

## Task 9 — Home Screen

**Files:**
- Modify: `lib/presentation/screens/home/home_screen.dart`
- Create: `lib/presentation/screens/home/widgets/ingredient_chip.dart`
- Create: `lib/presentation/screens/home/widgets/trending_card.dart`

- [ ] **Étape 1 : ingredient_chip.dart**

```dart
// lib/presentation/screens/home/widgets/ingredient_chip.dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final bool muted;

  const IngredientChip({
    super.key,
    required this.label,
    required this.onRemove,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: muted ? AppColors.surfaceContainerHigh : AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: muted ? AppColors.onSurfaceVariant : AppColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.close,
              size: 16,
              color: muted ? AppColors.onSurfaceVariant : AppColors.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Étape 2 : trending_card.dart**

```dart
// lib/presentation/screens/home/widgets/trending_card.dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class TrendingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;

  const TrendingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null
                ? Image.network(imageUrl!, width: 72, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 72, height: 72,
    decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(10)),
    child: const Icon(Icons.restaurant, color: AppColors.outlineVariant),
  );
}
```

- [ ] **Étape 3 : home_screen.dart (complet)**

```dart
// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../presentation/providers/ingredient_provider.dart';
import '../../../presentation/providers/recipe_match_provider.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/ingredient_chip.dart';
import 'widgets/trending_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  bool _spinning = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient() {
    ref.read(ingredientProvider.notifier).add(_controller.text);
    _controller.clear();
  }

  Future<void> _spin() async {
    final ingredients = ref.read(ingredientProvider);
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute au moins un ingrédient !')),
      );
      return;
    }
    setState(() => _spinning = true);
    await ref.read(recipeMatchProvider.notifier).spin();
    setState(() => _spinning = false);

    final match = ref.read(bestMatchProvider);
    if (match != null && mounted) {
      context.push(Routes.result, extra: match);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune recette trouvée avec ces ingrédients.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white.withOpacity(0.9),
            title: Text(
              'Leftover Roulette',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () {}, color: AppColors.primary),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero
                _HeroCard(),
                const SizedBox(height: 32),

                // Input
                _IngredientInput(controller: _controller, onAdd: _addIngredient),
                const SizedBox(height: 16),

                // Chips
                if (ingredients.isNotEmpty) ...[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ingredients.map((ing) => IngredientChip(
                      label: ing,
                      onRemove: () => ref.read(ingredientProvider.notifier).remove(ing),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Bento stats
                _BentoStats(wastePercent: ingredients.isEmpty ? 0 : 75),
                const SizedBox(height: 24),

                // CTA
                _SpinButton(spinning: _spinning, onPressed: _spin),
                const SizedBox(height: 32),

                // Trending
                Text('Trending Near You', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: const [
                  TrendingCard(title: 'Kitchen Sink Stir-fry', subtitle: '4 matches found'),
                  SizedBox(width: 16),
                  TrendingCard(title: 'Umami Leftover Melt', subtitle: '2 matches found'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("What's in\nyour fridge?",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.onSurface, height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text('Turn those lonely leftovers into a culinary masterpiece.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Positioned(
            right: -16, bottom: -20,
            child: Icon(Icons.restaurant, size: 100, color: AppColors.primary.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}

class _IngredientInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const _IngredientInput({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onAdd(),
            decoration: InputDecoration(
              hintText: 'Ajoute un ingrédient...',
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _BentoStats extends StatelessWidget {
  final int wastePercent;
  const _BentoStats({required this.wastePercent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$wastePercent%', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 36)),
                  const Spacer(),
                  Text('WASTE REDUCTION', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                  Text('Estimated impact', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 32),
                  const Spacer(),
                  Text('ECO FRIENDLY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                  Text('Locally sourced', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpinButton extends StatelessWidget {
  final bool spinning;
  final VoidCallback onPressed;

  const _SpinButton({required this.spinning, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: spinning ? null : onPressed,
        icon: spinning
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.casino, color: Colors.white),
        label: Text(
          spinning ? 'Spinning...' : 'Spin the Roulette',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}
```

- [ ] **Étape 4 : Tester visuellement**

```bash
flutter run
```

Expected : écran Home avec hero, input, bouton "Spin the Roulette". Ajouter des ingrédients crée des chips. Le spin navigue vers l'écran Result placeholder.

- [ ] **Étape 5 : Commit**

```bash
git add .
git commit -m "feat: home screen (ingredient input, chips, spin CTA)"
```

---

## Task 10 — Result Screen

**Files:**
- Create: `lib/presentation/screens/result/widgets/match_ring.dart`
- Create: `lib/presentation/screens/result/widgets/ingredient_list_item.dart`
- Modify: `lib/presentation/screens/result/result_screen.dart`

- [ ] **Étape 1 : match_ring.dart (SVG circulaire)**

```dart
// lib/presentation/screens/result/widgets/match_ring.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class MatchRing extends StatelessWidget {
  final double score; // 0.0 → 1.0
  final double size;

  const MatchRing({super.key, required this.score, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _RingPainter(score: score),
        child: Center(
          child: Icon(Icons.eco, color: AppColors.secondary, size: size * 0.35),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score;
  const _RingPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(rect, 0, 2 * pi, false,
      Paint()..color = AppColors.surfaceContainerHighest..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Progress arc
    canvas.drawArc(rect, -pi / 2, 2 * pi * score, false,
      Paint()..color = AppColors.secondary..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.score != score;
}
```

- [ ] **Étape 2 : ingredient_list_item.dart**

```dart
// lib/presentation/screens/result/widgets/ingredient_list_item.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/ingredient.dart';
import '../../../theme/app_colors.dart';

class IngredientListItem extends StatelessWidget {
  final Ingredient ingredient;
  final bool owned;
  final VoidCallback? onAddToList;

  const IngredientListItem({
    super.key,
    required this.ingredient,
    required this.owned,
    this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: owned ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: owned ? null : Border(
          left: const BorderSide(color: AppColors.primary, width: 4),
          right: BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
          top:   BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
          bottom:BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: owned ? AppColors.secondaryContainer : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              owned ? Icons.check_circle : Icons.add,
              color: owned ? AppColors.onSecondaryContainer : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                if (!owned && ingredient.amount.isNotEmpty)
                  Text(ingredient.amount, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          if (!owned && onAddToList != null)
            GestureDetector(
              onTap: onAddToList,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Add to List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Étape 3 : result_screen.dart**

```dart
// lib/presentation/screens/result/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/recipe_match.dart';
import '../../../presentation/providers/shopping_list_provider.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/match_ring.dart';
import 'widgets/ingredient_list_item.dart';

class ResultScreen extends ConsumerWidget {
  final RecipeMatch? match;

  const ResultScreen({super.key, this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat')),
        body: const Center(child: Text('Aucun résultat')),
      );
    }

    final recipe = match!.recipe;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.imageUrl != null)
                    Image.network(recipe.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.primaryContainer))
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryContainer],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 120, left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(100)),
                      child: Text('MATCH FOUND',
                        style: TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2)),
                    ),
                  ),
                  Positioned(
                    bottom: 24, left: 24, right: 24,
                    child: Text(recipe.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32, shadows: [Shadow(blurRadius: 8, color: Colors.black38)])),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Score cards
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Stock Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text('${match!.matchPercent}%',
                                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 48)),
                                const Text('de tes ingrédients', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                            const Spacer(),
                            MatchRing(score: match!.matchScore),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
                            const SizedBox(height: 8),
                            Text('${recipe.cookTimeMinutes}m',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                            const Text('Cook Time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Ingredients
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ingredients', style: Theme.of(context).textTheme.headlineSmall),
                    Text('${recipe.ingredients.length} items',
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                if (match!.matchedIngredients.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('IN YOUR PANTRY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.secondary)),
                  ),
                  ...match!.matchedIngredients.map((ing) => IngredientListItem(ingredient: ing, owned: true)),
                ],
                if (match!.missingIngredients.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('MISSING ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.primary)),
                  ),
                  ...match!.missingIngredients.map((ing) => IngredientListItem(
                    ingredient: ing,
                    owned: false,
                    onAddToList: () => ref.read(addToShoppingListUseCaseProvider).execute(ing, match!),
                  )),
                ],
                const SizedBox(height: 28),

                // CTA
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(Routes.cooking, extra: match),
                    icon: const Icon(Icons.restaurant, color: Colors.white),
                    label: const Text('Start Cooking Now', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Spin Again'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Étape 4 : Test visuel**

```bash
flutter run
```

Ajouter "oignon" + "bacon" → Spin → vérifier que la Result Screen affiche Quiche Lorraine avec 50%, les ingrédients matchés en vert, et les manquants en orange avec "Add to List".

- [ ] **Étape 5 : Commit**

```bash
git add .
git commit -m "feat: result screen (match ring, ingredient list, CTA)"
```

---

## Task 11 — Shopping Screen

**Files:**
- Create: `lib/presentation/screens/shopping/widgets/shopping_item_tile.dart`
- Modify: `lib/presentation/screens/shopping/shopping_screen.dart`

- [ ] **Étape 1 : shopping_item_tile.dart**

```dart
// lib/presentation/screens/shopping/widgets/shopping_item_tile.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/shopping_item.dart';
import '../../../theme/app_colors.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final ValueChanged<bool> onToggle;

  const ShoppingItemTile({super.key, required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!item.checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: item.checked ? AppColors.secondary : AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: item.checked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decoration: item.checked ? TextDecoration.lineThrough : null,
                      color: item.checked ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    ),
                  ),
                  if (item.category.isNotEmpty)
                    Text(item.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Étape 2 : shopping_screen.dart**

```dart
// lib/presentation/screens/shopping/shopping_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../presentation/providers/shopping_list_provider.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/shopping_item_tile.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Shopping', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => ref.read(shoppingRepositoryProvider).clearChecked(),
            child: const Text('Supprimer cochés', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 64, color: AppColors.outlineVariant),
                  SizedBox(height: 16),
                  Text('Ta liste est vide', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  SizedBox(height: 8),
                  Text('Ajoute des ingrédients depuis la page Résultat', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final unchecked = items.where((i) => !i.checked).toList();
          final checked   = items.where((i) => i.checked).toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text('Current Mission', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...unchecked.map((item) => ShoppingItemTile(
                      item: item,
                      onToggle: (v) => ref.read(shoppingRepositoryProvider).toggleItem(item.id, v),
                    )),
                    if (checked.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      ...checked.map((item) => ShoppingItemTile(
                        item: item,
                        onToggle: (v) => ref.read(shoppingRepositoryProvider).toggleItem(item.id, v),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Étape 3 : Commit**

```bash
git add .
git commit -m "feat: shopping screen (live list, toggle, clear)"
```

---

## Task 12 — Cooking Screen

**Files:**
- Create: `lib/presentation/screens/cooking/widgets/recipe_step_card.dart`
- Create: `lib/presentation/screens/cooking/widgets/cooking_timer.dart`
- Modify: `lib/presentation/screens/cooking/cooking_screen.dart`

- [ ] **Étape 1 : recipe_step_card.dart**

```dart
// lib/presentation/screens/cooking/widgets/recipe_step_card.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/recipe.dart';
import '../../../theme/app_colors.dart';

class RecipeStepCard extends StatelessWidget {
  final RecipeStep step;
  final bool isActive;

  const RecipeStepCard({super.key, required this.step, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isActive
          ? [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))]
          : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
        border: isActive ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8, right: -8,
            child: Text(
              '${step.order}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 72,
                color: AppColors.surfaceContainerHigh.withOpacity(isActive ? 0.5 : 0.8),
                height: 1,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title,
                style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18,
                  decoration: isActive ? TextDecoration.none : null,
                )),
              const SizedBox(height: 10),
              Text(step.description,
                style: const TextStyle(color: AppColors.onSurfaceVariant, height: 1.6, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('${step.durationMinutes} min',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Étape 2 : cooking_timer.dart**

```dart
// lib/presentation/screens/cooking/widgets/cooking_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CookingTimer extends StatefulWidget {
  final int initialMinutes;

  const CookingTimer({super.key, required this.initialMinutes});

  @override
  State<CookingTimer> createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer> {
  late int _remaining; // seconds
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_running) {
        _timer?.cancel();
        _running = false;
      } else {
        _running = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (_remaining > 0) {
            setState(() => _remaining--);
          } else {
            _timer?.cancel();
            setState(() => _running = false);
          }
        });
      }
    });
  }

  String get _display {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_display, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_running ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(_running ? 'Pause' : 'Start', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Étape 3 : cooking_screen.dart**

```dart
// lib/presentation/screens/cooking/cooking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/recipe_match.dart';
import '../../../presentation/theme/app_colors.dart';
import 'widgets/recipe_step_card.dart';
import 'widgets/cooking_timer.dart';

class CookingScreen extends StatefulWidget {
  final RecipeMatch? match;
  const CookingScreen({super.key, this.match});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  int _activeStep = 0;

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    if (match == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('No recipe')));
    final recipe = match.recipe;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text('Leftover Roulette',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            actions: [
              IconButton(icon: const Icon(Icons.favorite_border, color: AppColors.primary), onPressed: () {}),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(100)),
                  child: Text('CHEF\'S PICK',
                    style: TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.5)),
                ).also((w) => w),
                const SizedBox(height: 12),
                Text(recipe.name,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${recipe.cookTimeMinutes} mins', style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    const Icon(Icons.bolt, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(recipe.difficulty, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats bento
                Row(
                  children: [
                    _StatCard(label: 'Waste Saved', value: '${match.matchPercent}%', color: AppColors.secondary),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Portions', value: '${recipe.servingsMin}-${recipe.servingsMax}', color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 24),

                // Timer + header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Préparation', style: Theme.of(context).textTheme.headlineSmall),
                    CookingTimer(initialMinutes: recipe.cookTimeMinutes),
                  ],
                ),
                const SizedBox(height: 20),

                // Steps
                ...recipe.steps.asMap().entries.map((e) => GestureDetector(
                  onTap: () => setState(() => _activeStep = e.key),
                  child: RecipeStepCard(step: e.value, isActive: e.key == _activeStep),
                )),
                const SizedBox(height: 16),

                // Pro tip
                if (match.matchedIngredients.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.secondary),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Pro-tip : Tu as déjà ${match.matchedIngredients.map((i) => i.name).join(", ")} — utilise-les en premier pour éviter le gaspillage.',
                            style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: color)),
          ],
        ),
      ),
    );
  }
}

// Dart extension helper used in build method
extension on Widget {
  Widget also(void Function(Widget) fn) { fn(this); return this; }
}
```

> **Note :** Supprimer l'extension `.also` et corriger la première Card du SliverList — elle utilise `.also()` pour rien. Remplacer le bloc `Container(...).also((w) => w)` par le `Container` seul sans `.also`.

- [ ] **Étape 4 : Fix cooking_screen.dart** (supprimer `.also`)

Remplacer :
```dart
Container(...).also((w) => w),
```
par :
```dart
Align(
  alignment: Alignment.centerLeft,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(100)),
    child: const Text('CHEF\'S PICK',
      style: TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.5)),
  ),
),
```

Et supprimer l'extension `.also` en bas du fichier.

- [ ] **Étape 5 : Test du flux complet**

```bash
flutter run
```

Tester le flux complet : Home → ajouter "oignon" + "sauce soja" → Spin → Result (Stir-fry, 100%) → Add to List → Start Cooking → voir les étapes avec timer.

- [ ] **Étape 6 : Commit**

```bash
git add .
git commit -m "feat: cooking screen (steps, timer, pro-tip)"
```

---

## Task 13 — Firestore Seeder

**Files:**
- Create: `scripts/package.json`
- Create: `scripts/seed_firestore.js`

- [ ] **Étape 1 : package.json**

```json
{
  "name": "leftover-roulette-scripts",
  "version": "1.0.0",
  "scripts": {
    "seed": "node seed_firestore.js"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0"
  }
}
```

- [ ] **Étape 2 : seed_firestore.js**

```js
// scripts/seed_firestore.js
// Usage: GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node seed_firestore.js

const admin = require('firebase-admin');
admin.initializeApp({ credential: admin.credential.applicationDefault() });
const db = admin.firestore();

const recipes = [
  {
    name: 'Quiche Lorraine',
    imageUrl: null,
    cookTimeMinutes: 45,
    servings: { min: 2, max: 4 },
    difficulty: 'intermediate',
    tags: ['french', 'savory', 'oven'],
    ingredients: [
      { name: 'oignon', amount: '1 demi', category: 'produce', aliases: ['onion'] },
      { name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon', 'pancetta'] },
      { name: 'pâte à tarte', amount: '1', category: 'pastry', aliases: ['pie crust'] },
      { name: 'crème fraîche', amount: '200ml', category: 'dairy', aliases: ['cream'] },
      { name: 'fromage râpé', amount: '100g', category: 'dairy', aliases: ['cheese', 'gruyere', 'fromage frais', 'cream cheese'] },
    ],
    steps: [
      { order: 1, title: 'Préchauffage & fond de tarte', description: 'Préchauffez le four à 200°C. Étalez la pâte dans un moule. Faites cuire à blanc 8 min.', durationMinutes: 10 },
      { order: 2, title: 'La préparation', description: 'Battez 4 œufs avec la crème. Incorporez lardons et oignon émincé. Assaisonnez avec muscade.', durationMinutes: 10 },
      { order: 3, title: 'Cuisson', description: 'Versez dans le fond de tarte. Parsemez de fromage. Enfournez 15-18 min jusqu\'à dorure.', durationMinutes: 18 },
    ],
  },
  {
    name: 'Kitchen Sink Stir-fry',
    imageUrl: null,
    cookTimeMinutes: 20,
    servings: { min: 2, max: 3 },
    difficulty: 'easy',
    tags: ['asian', 'quick', 'wok'],
    ingredients: [
      { name: 'sauce soja', amount: '3 cuil.', category: 'pantry', aliases: ['soy sauce'] },
      { name: 'oignon', amount: '1', category: 'produce', aliases: ['onion'] },
      { name: 'ail', amount: '2 gousses', category: 'produce', aliases: ['garlic'] },
      { name: 'huile de sésame', amount: '1 cuil.', category: 'pantry', aliases: ['sesame oil'] },
    ],
    steps: [
      { order: 1, title: 'Préparation', description: 'Émincer oignon et ail.', durationMinutes: 5 },
      { order: 2, title: 'Wok', description: 'Chauffer huile, faire revenir oignon 2 min, ajouter ail et sauce soja.', durationMinutes: 10 },
      { order: 3, title: 'Service', description: 'Servir sur riz ou nouilles.', durationMinutes: 2 },
    ],
  },
];

async function seed() {
  const batch = db.batch();
  for (const recipe of recipes) {
    const ref = db.collection('recipes').doc();
    batch.set(ref, { ...recipe, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  }
  await batch.commit();
  console.log(`✅ Seeded ${recipes.length} recipes`);
  process.exit(0);
}

seed().catch(console.error);
```

- [ ] **Étape 3 : Lancer le seeder**

```bash
cd scripts
npm install
# Télécharger la clé de service depuis Firebase Console > Settings > Service accounts
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node seed_firestore.js
```

Expected : `✅ Seeded 2 recipes`

- [ ] **Étape 4 : Activer Firebase dans repository_providers.dart**

Changer `const _useFirebase = false;` en `const _useFirebase = true;`.

- [ ] **Étape 5 : Commit**

```bash
git add scripts/ lib/core/providers/
git commit -m "feat: firestore seeder + enable firebase data source"
```

---

## Task 14 — Tests & Polissage final

**Files:**
- Create: `test/presentation/home_screen_test.dart`

- [ ] **Étape 1 : Widget test Home Screen**

```dart
// test/presentation/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leftover_roulette/presentation/screens/home/home_screen.dart';
import 'package:leftover_roulette/core/router/app_router.dart';

void main() {
  testWidgets('HomeScreen shows title and spin button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: const HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Leftover Roulette'), findsOneWidget);
    expect(find.text('Spin the Roulette'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Adding ingredient creates a chip', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: const HomeScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'oignon');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('oignon'), findsOneWidget);
  });
}
```

- [ ] **Étape 2 : Lancer tous les tests**

```bash
flutter test
```

Expected : tous les tests passent (domain + presentation).

- [ ] **Étape 3 : Vérifier la compilation release**

```bash
# Android
flutter build apk --release

# iOS (nécessite Xcode sur macOS)
flutter build ios --release --no-codesign
```

- [ ] **Étape 4 : Commit final**

```bash
git add .
git commit -m "feat: widget tests, final build verification"
```

---

## Checklist de couverture

| Fonctionnalité                | Tâche     | Statut |
|-------------------------------|-----------|--------|
| Scaffold Flutter + deps       | Task 1    | ☐      |
| Thème MD3 + couleurs app      | Task 2    | ☐      |
| Firebase init + FlutterFire   | Task 3    | ☐      |
| Entities (Ingredient, Recipe…)| Task 4    | ☐      |
| Matching algorithm            | Task 5    | ☐      |
| Shopping use case             | Task 5    | ☐      |
| Tests unitaires matching      | Task 5    | ☐      |
| Mock repository (sans Firebase)| Task 6   | ☐      |
| Firebase data source          | Task 6    | ☐      |
| Shopping Firestore sync       | Task 6    | ☐      |
| Riverpod providers            | Task 7    | ☐      |
| GoRouter + bottom nav         | Task 8    | ☐      |
| Home Screen complet           | Task 9    | ☐      |
| Result Screen + MatchRing     | Task 10   | ☐      |
| Shopping Screen + live stream | Task 11   | ☐      |
| Cooking Screen + timer        | Task 12   | ☐      |
| Firestore seeder              | Task 13   | ☐      |
| Widget tests                  | Task 14   | ☐      |
| Build release APK/iOS         | Task 14   | ☐      |
