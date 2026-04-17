import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ShoppingRepositoryImpl(this._db, this._auth);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'ShoppingRepository requires an authenticated user. '
        'Call Firebase Auth sign-in before accessing the shopping list.',
      );
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _col => _db
      .collection('users')
      .doc(_uid)
      .collection('shoppingLists')
      .doc('current')
      .collection('items');

  @override
  Stream<List<ShoppingItem>> watchItems() {
    return _col.orderBy('addedAt').snapshots().map(
          (s) => s.docs.map(_fromDoc).toList(),
        );
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
    const chunkSize = 500;
    final checked = await _col.where('checked', isEqualTo: true).get();
    for (var i = 0; i < checked.docs.length; i += chunkSize) {
      final batch = _db.batch();
      for (final doc in checked.docs.skip(i).take(chunkSize)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  ShoppingItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
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
