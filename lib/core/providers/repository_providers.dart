// lib/core/providers/repository_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_recipe_source.dart';
import '../../data/datasources/mistral_recipe_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/mock_history_repository.dart';
import '../../data/repositories/mock_recipe_repository.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/mock_shopping_repository.dart';
import '../../data/repositories/shopping_repository_impl.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../domain/use_cases/add_to_shopping_list_use_case.dart';
import '../../domain/use_cases/generate_recipe_use_case.dart';
import '../../domain/use_cases/match_recipes_use_case.dart';

import '../../env.dart';
import '../../presentation/providers/user_settings_provider.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  if (Env.useFirebase) {
    return RecipeRepositoryImpl(
      FirebaseRecipeSource(FirebaseFirestore.instance),
    );
  }
  return MockRecipeRepository();
});

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  if (Env.useFirebase) {
    return ShoppingRepositoryImpl(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  }
  return MockShoppingRepository();
});

final matchRecipesUseCaseProvider = Provider<MatchRecipesUseCase>((ref) {
  return MatchRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final addToShoppingListUseCaseProvider = Provider<AddToShoppingListUseCase>((ref) {
  return AddToShoppingListUseCase(ref.watch(shoppingRepositoryProvider));
});

final mistralRecipeSourceProvider = Provider<MistralRecipeSource>((ref) {
  final apiKey = ref.watch(effectiveMistralApiKeyProvider);
  return MistralRecipeSource(apiKey: apiKey);
});

final generateRecipeUseCaseProvider = Provider<GenerateRecipeUseCase>((ref) {
  return GenerateRecipeUseCase(
    ref.watch(mistralRecipeSourceProvider),
    ref.watch(recipeRepositoryProvider),
  );
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  if (Env.useFirebase) {
    return HistoryRepositoryImpl(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  }
  return MockHistoryRepository();
});
