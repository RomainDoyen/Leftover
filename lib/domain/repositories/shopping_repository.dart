import '../entities/shopping_item.dart';

abstract class ShoppingRepository {
  /// Stream of shopping items for the current user.
  Stream<List<ShoppingItem>> watchItems();

  /// Add an item to the shopping list.
  Future<void> addItem(ShoppingItem item);

  /// Toggle checked state of an item.
  Future<void> toggleItem(String itemId, bool checked);

  /// Remove all checked items.
  Future<void> clearChecked();
}
