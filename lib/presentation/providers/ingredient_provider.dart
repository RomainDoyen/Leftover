// lib/presentation/providers/ingredient_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IngredientNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String ingredient) {
    final trimmed = ingredient.trim().toLowerCase();
    if (trimmed.isEmpty || state.contains(trimmed)) return;
    state = [...state, trimmed];
  }

  void remove(String ingredient) {
    final trimmed = ingredient.trim().toLowerCase();
    state = state.where((i) => i != trimmed).toList();
  }

  void clear() => state = [];
}

final ingredientProvider =
    NotifierProvider<IngredientNotifier, List<String>>(IngredientNotifier.new);
