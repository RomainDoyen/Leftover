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

  Future<void> save(Recipe recipe) async {
    await _db.collection('recipes').doc(recipe.id).set({
      'name':            recipe.name,
      'imageUrl':        recipe.imageUrl,
      'cookTimeMinutes': recipe.cookTimeMinutes,
      'servings': {
        'min': recipe.servingsMin,
        'max': recipe.servingsMax,
      },
      'difficulty': recipe.difficulty,
      'tags':       recipe.tags,
      'source':     'ai',
      'ingredients': recipe.ingredients.map((i) => {
        'name':     i.name,
        'amount':   i.amount,
        'category': i.category,
        'aliases':  i.aliases,
      }).toList(),
      'steps': recipe.steps.map((s) => {
        'order':           s.order,
        'title':           s.title,
        'description':     s.description,
        'durationMinutes': s.durationMinutes,
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Recipe _fromDoc(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      name: data['name'] as String? ?? (throw FormatException('Recipe ${doc.id} missing field: name')),
      imageUrl: data['imageUrl'] as String?,
      cookTimeMinutes: (data['cookTimeMinutes'] as num?)?.toInt() ?? 30,
      servingsMin: (data['servings']?['min'] as num? ?? 2).toInt(),
      servingsMax: (data['servings']?['max'] as num? ?? 4).toInt(),
      difficulty: data['difficulty'] as String? ?? 'easy',
      tags: List<String>.from(data['tags'] ?? []),
      ingredients: (data['ingredients'] as List<dynamic>? ?? [])
          .map((i) => Ingredient(
                name: i['name'] as String? ?? (throw FormatException('Ingredient in ${doc.id} missing field: name')),
                amount: i['amount'] as String? ?? '',
                category: i['category'] as String? ?? 'pantry',
                aliases: List<String>.from(i['aliases'] ?? []),
              ))
          .toList(),
      steps: (data['steps'] as List<dynamic>? ?? [])
          .map((s) => RecipeStep(
                order: (s['order'] as num?)?.toInt() ?? 0,
                title: s['title'] as String? ?? '',
                description: s['description'] as String? ?? '',
                durationMinutes: (s['durationMinutes'] as num? ?? 5).toInt(),
              ))
          .toList(),
    );
  }
}
