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

  Recipe _fromDoc(QueryDocumentSnapshot<Object?> doc) {
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
