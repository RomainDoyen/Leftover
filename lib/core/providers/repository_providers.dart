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

/// Set to true to use real Firebase data. Set to false for mock data (no Firebase needed).
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
