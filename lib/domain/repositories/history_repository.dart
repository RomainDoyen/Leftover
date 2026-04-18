import '../entities/history_entry.dart';

abstract class HistoryRepository {
  /// Stream of history entries, most recent first.
  Stream<List<HistoryEntry>> watchHistory();

  /// Persist a spin result to history.
  Future<void> saveEntry(HistoryEntry entry);

  /// Remove a single entry.
  Future<void> deleteEntry(String entryId);
}
