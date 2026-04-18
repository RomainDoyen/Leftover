import 'dart:async';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';

class MockHistoryRepository implements HistoryRepository {
  final _items = <HistoryEntry>[];
  final _controller =
      StreamController<List<HistoryEntry>>.broadcast();

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Stream<List<HistoryEntry>> watchHistory() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> saveEntry(HistoryEntry entry) async {
    _items.insert(0, entry);
    _emit();
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    _items.removeWhere((e) => e.id == entryId);
    _emit();
  }
}
