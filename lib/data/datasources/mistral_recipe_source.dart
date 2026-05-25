import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';

/// Calls the Mistral API to generate a recipe from a list of ingredients.
/// API key is supplied by the user (Profil) or read from lib/env.dart (dev).
class MistralRecipeSource {
  final String apiKey;

  const MistralRecipeSource({required this.apiKey});

  static const _endpoint = 'https://api.mistral.ai/v1/chat/completions';
  static const _model    = 'mistral-small-latest';

  bool get isAvailable =>
      apiKey.isNotEmpty && apiKey != 'REMPLACE_PAR_TA_CLE_MISTRAL';

  Future<Recipe> generateFromIngredients(List<String> ingredients) async {
    assert(isAvailable, 'MISTRAL_API_KEY is not set.');

    final prompt = '''Tu es un chef cuisinier créatif et pratique.
L'utilisateur a ces ingrédients disponibles : ${ingredients.join(', ')}.

Génère UNE recette réaliste et savoureuse qui utilise le MAXIMUM de ces ingrédients. La recette doit être faisable à la maison sans équipement professionnel.

Réponds UNIQUEMENT avec un objet JSON valide (sans texte avant ni après) avec exactement ce format :
{
  "name": "Nom de la recette en français",
  "cookTimeMinutes": 20,
  "servingsMin": 2,
  "servingsMax": 4,
  "difficulty": "facile",
  "tags": ["tag1", "tag2"],
  "ingredients": [
    {"name": "nom ingrédient", "amount": "quantité", "category": "produce", "aliases": ["alias_en_anglais"]}
  ],
  "steps": [
    {"order": 1, "title": "Titre de l'étape", "description": "Description détaillée de l'étape.", "durationMinutes": 5}
  ]
}

Règles :
- difficulty : "facile", "intermédiaire" ou "difficile" uniquement
- category : "produce", "proteins", "dairy", "pantry" ou "pastry" uniquement
- Minimum 2 étapes, maximum 5
- Les noms d'ingrédients en français, les aliases en anglais''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.75,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Mistral API ${response.statusCode}: ${response.body}');
    }

    final data    = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['choices'] as List).first['message']['content'] as String;
    final recipe  = jsonDecode(content) as Map<String, dynamic>;

    return _parse(recipe);
  }

  Recipe _parse(Map<String, dynamic> d) {
    final ingredients = (d['ingredients'] as List? ?? []).map((i) {
      final m = i as Map<String, dynamic>;
      return Ingredient(
        name:     m['name']     as String? ?? '',
        amount:   m['amount']   as String? ?? '',
        category: m['category'] as String? ?? 'pantry',
        aliases: (m['aliases'] as List?)
                ?.map((a) => a as String)
                .toList() ??
            [],
      );
    }).toList();

    final steps = (d['steps'] as List? ?? []).map((s) {
      final m = s as Map<String, dynamic>;
      return RecipeStep(
        order:           (m['order']           as num?)?.toInt() ?? 1,
        title:            m['title']            as String? ?? '',
        description:      m['description']      as String? ?? '',
        durationMinutes: (m['durationMinutes'] as num?)?.toInt() ?? 5,
      );
    }).toList();

    return Recipe(
      id:              'ai-${DateTime.now().millisecondsSinceEpoch}',
      name:             d['name']            as String? ?? 'Recette générée',
      cookTimeMinutes: (d['cookTimeMinutes'] as num?)?.toInt() ?? 20,
      servingsMin:     (d['servingsMin']     as num?)?.toInt() ?? 2,
      servingsMax:     (d['servingsMax']     as num?)?.toInt() ?? 4,
      difficulty:       d['difficulty']      as String? ?? 'facile',
      tags: (d['tags'] as List?)?.map((t) => t as String).toList() ?? [],
      ingredients: ingredients,
      steps:        steps,
    );
  }
}
