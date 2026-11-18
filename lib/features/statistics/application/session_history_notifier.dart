import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_provider.dart';
import '../domain/game_session_record.dart';

class SessionHistoryNotifier extends Notifier<List<GameSessionRecord>> {
  @override
  List<GameSessionRecord> build() {
    return _loadFromStorage();
  }

  LocalStorageService get _storage => ref.read(localStorageProvider);

  List<GameSessionRecord> _loadFromStorage() {
    final records = <GameSessionRecord>[];
    for (final raw in _storage.rawSessionHistory) {
      final record = GameSessionRecord.tryParse(raw);
      if (record != null) {
        records.add(record);
      }
    }
    records.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return List<GameSessionRecord>.unmodifiable(records);
  }

  /// Appends a completed session when [record.id] is new.
  void record(GameSessionRecord record) {
    if (record.id.isEmpty) {
      return;
    }
    if (state.any((existing) => existing.id == record.id)) {
      return;
    }

    final next = List<GameSessionRecord>.from(state)..add(record);
    if (next.length > LocalStorageService.maxSessionHistory) {
      next.removeRange(0, next.length - LocalStorageService.maxSessionHistory);
    }
    state = List<GameSessionRecord>.unmodifiable(next);
    // Fire-and-forget persistence — same pattern as title progress.
    _storage.appendSessionRecord(record.toMap());
  }
}

final sessionHistoryProvider =
    NotifierProvider<SessionHistoryNotifier, List<GameSessionRecord>>(
  SessionHistoryNotifier.new,
);
