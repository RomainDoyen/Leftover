import 'package:flutter/material.dart';
import '../../../domain/entities/recipe_match.dart';

class ResultScreen extends StatelessWidget {
  final RecipeMatch? match;
  const ResultScreen({super.key, this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(child: Text(match?.recipe.name ?? 'No match')),
    );
  }
}
