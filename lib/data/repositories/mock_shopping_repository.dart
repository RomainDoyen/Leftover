// lib/data/repositories/mock_shopping_repository.dart
import 'dart:async';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

/// In-memory shopping repository for use when Firebase is not configured.
class MockShoppingRepository implements ShoppingRepository {
  final _items = <ShoppingItem>[];
  final StreamController<List<ShoppingItem>> _controller =
      StreamController<List<ShoppingItem>>.broadcast();

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Stream<List<ShoppingItem>> watchItems() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> addItem(ShoppingItem item) async {
    _items.add(item);
    _emit();
  }

  @override
  Future<void> toggleItem(String itemId, bool checked) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(checked: checked);
      _emit();
    }
  }

  @override
  Future<void> clearChecked() async {
    _items.removeWhere((i) => i.checked);
    _emit();
  }
}
