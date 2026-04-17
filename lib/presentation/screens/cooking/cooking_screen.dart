import 'package:flutter/material.dart';
import '../../../domain/entities/recipe_match.dart';

class CookingScreen extends StatelessWidget {
  final RecipeMatch? match;
  const CookingScreen({super.key, this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cooking')),
      body: Center(child: Text(match?.recipe.name ?? 'No recipe')),
    );
  }
}
