import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../domain/entities/history_entry.dart';

final historyProvider = StreamProvider<List<HistoryEntry>>((ref) {
  return ref.watch(historyRepositoryProvider).watchHistory();
});
