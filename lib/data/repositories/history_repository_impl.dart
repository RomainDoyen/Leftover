import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_match.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  HistoryRepositoryImpl(this._db, this._auth);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'HistoryRepository requires an authenticated user.',
      );
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('history');

  @override
  Stream<List<HistoryEntry>> watchHistory() {
    // orderBy is intentionally omitted here: Firestore may surface a missing
    // index as permission-denied on new collections. Sorting is done client-side.
    return _col.snapshots().map((s) {
      final entries = s.docs.map(_fromDoc).toList();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    });
  }

  @override
  Future<void> saveEntry(HistoryEntry entry) async {
    final r = entry.match.recipe;
    await _col.doc(entry.id).set({
      'source':           entry.source,
      'userIngredients':  entry.userIngredients,
      'createdAt':        FieldValue.serverTimestamp(),
      'matchScore':       entry.match.matchScore,
      'matchedIngredients': entry.match.matchedIngredients
          .map(_ingredientToMap)
          .toList(),
      'missingIngredients': entry.match.missingIngredients
          .map(_ingredientToMap)
          .toList(),
      'recipe': {
        'id':              r.id,
        'name':            r.name,
        'imageUrl':        r.imageUrl,
        'cookTimeMinutes': r.cookTimeMinutes,
        'servingsMin':     r.servingsMin,
        'servingsMax':     r.servingsMax,
        'difficulty':      r.difficulty,
        'tags':            r.tags,
        'ingredients':     r.ingredients.map(_ingredientToMap).toList(),
        'steps': r.steps
            .map((s) => {
                  'order':           s.order,
                  'title':           s.title,
                  'description':     s.description,
                  'durationMinutes': s.durationMinutes,
                })
            .toList(),
      },
    });
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await _col.doc(entryId).delete();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _ingredientToMap(Ingredient i) => {
        'name':     i.name,
        'amount':   i.amount,
        'category': i.category,
        'aliases':  i.aliases,
      };

  HistoryEntry _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final r = d['recipe'] as Map<String, dynamic>;
    final recipe = Recipe(
      id:              r['id'] as String,
      name:            r['name'] as String,
      imageUrl:        r['imageUrl'] as String?,
      cookTimeMinutes: (r['cookTimeMinutes'] as num).toInt(),
      servingsMin:     (r['servingsMin'] as num).toInt(),
      servingsMax:     (r['servingsMax'] as num).toInt(),
      difficulty:      r['difficulty'] as String,
      tags:            List<String>.from(r['tags'] ?? []),
      ingredients:     _parseIngredients(r['ingredients']),
      steps:           _parseSteps(r['steps']),
    );
    return HistoryEntry(
      id:              doc.id,
      match: RecipeMatch(
        recipe:             recipe,
        matchScore:         (d['matchScore'] as num).toDouble(),
        matchedIngredients: _parseIngredients(d['matchedIngredients']),
        missingIngredients: _parseIngredients(d['missingIngredients']),
      ),
      userIngredients: List<String>.from(d['userIngredients'] ?? []),
      source:          d['source'] as String? ?? 'match',
      createdAt:       (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  List<Ingredient> _parseIngredients(dynamic raw) =>
      (raw as List<dynamic>? ?? [])
          .map((i) => Ingredient(
                name:     i['name'] as String,
                amount:   i['amount'] as String? ?? '',
                category: i['category'] as String? ?? 'pantry',
                aliases:  List<String>.from(i['aliases'] ?? []),
              ))
          .toList();

  List<RecipeStep> _parseSteps(dynamic raw) =>
      (raw as List<dynamic>? ?? [])
          .map((s) => RecipeStep(
                order:           (s['order'] as num).toInt(),
                title:           s['title'] as String? ?? '',
                description:     s['description'] as String? ?? '',
                durationMinutes: (s['durationMinutes'] as num? ?? 5).toInt(),
              ))
          .toList();
}
