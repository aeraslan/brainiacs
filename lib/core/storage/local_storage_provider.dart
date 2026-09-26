import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../rank/title_tier.dart';
import '../session/game_session_state.dart';

/// Typed access to player progress (Hive `userData` box, or in-memory for tests).
class LocalStorageService {
  LocalStorageService(Box<dynamic> box)
      : _box = box,
        _memory = null;

  /// In-memory backend for unit/widget tests (no Hive init required).
  LocalStorageService.memory([Map<String, dynamic>? initial])
      : _box = null,
        _memory = Map<String, dynamic>.from(initial ?? const {});

  static const String boxName = 'userData';

  static const String highestScoreKey = 'highestScore';
  static const String highestScoreMathKey = 'highestScoreMath';
  static const String highestScoreMemoryKey = 'highestScoreMemory';
  static const String highestScoreAnalyticalKey = 'highestScoreAnalytical';
  static const String highestScoreVisualKey = 'highestScoreVisual';
  static const String currentRankIndexKey = 'currentRankIndex';
  static const String totalGamesPlayedKey = 'totalGamesPlayed';
  static const String lastPlayedDateKey = 'lastPlayedDate';
  static const String prefsMigratedKey = 'prefsMigrated';

  /// Legacy SharedPreferences keys (pre-Hive).
  static const String legacyHighestTitleKey = 'highest_title';
  static const String legacyLastEarnedDateKey = 'last_earned_date';

  static const Map<MiniGameType, String> categoryHighScoreKeys = {
    MiniGameType.math: highestScoreMathKey,
    MiniGameType.memory: highestScoreMemoryKey,
    MiniGameType.analytical: highestScoreAnalyticalKey,
    MiniGameType.visual: highestScoreVisualKey,
  };

  final Box<dynamic>? _box;
  final Map<String, dynamic>? _memory;

  dynamic _get(String key) {
    final box = _box;
    if (box != null) {
      return box.get(key);
    }
    return _memory![key];
  }

  Future<void> _put(String key, dynamic value) {
    final box = _box;
    if (box != null) {
      return box.put(key, value);
    }
    _memory![key] = value;
    return Future<void>.value();
  }

  Future<void> _delete(String key) {
    final box = _box;
    if (box != null) {
      return box.delete(key);
    }
    _memory!.remove(key);
    return Future<void>.value();
  }

  bool _containsKey(String key) {
    final box = _box;
    if (box != null) {
      return box.containsKey(key);
    }
    return _memory!.containsKey(key);
  }

  int get highestScore => (_get(highestScoreKey) as int?) ?? 0;

  int highestScoreFor(MiniGameType type) {
    final key = categoryHighScoreKeys[type];
    if (key == null) {
      return 0;
    }
    return (_get(key) as int?) ?? 0;
  }

  Map<MiniGameType, int> get highestScoresByGame {
    return {
      for (final type in MiniGameType.values) type: highestScoreFor(type),
    };
  }

  int get currentRankIndex {
    final raw = (_get(currentRankIndexKey) as int?) ?? 0;
    if (raw < 0) {
      return 0;
    }
    final maxIndex = TitleTier.values.length - 1;
    if (raw > maxIndex) {
      return maxIndex;
    }
    return raw;
  }

  int get totalGamesPlayed => (_get(totalGamesPlayedKey) as int?) ?? 0;

  DateTime? get lastPlayedDate {
    final raw = _get(lastPlayedDateKey) as String?;
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  bool get prefsMigrated => (_get(prefsMigratedKey) as bool?) ?? false;

  Future<void> setHighestScore(int value) => _put(highestScoreKey, value);

  Future<void> setCurrentRankIndex(int value) =>
      _put(currentRankIndexKey, value);

  Future<void> setTotalGamesPlayed(int value) =>
      _put(totalGamesPlayedKey, value);

  Future<void> setLastPlayedDate(DateTime? value) {
    if (value == null) {
      return _delete(lastPlayedDateKey);
    }
    return _put(lastPlayedDateKey, value.toIso8601String());
  }

  Future<void> persistProgress({
    required int highestScore,
    required Map<MiniGameType, int> highestScoresByGame,
    required int currentRankIndex,
    required int totalGamesPlayed,
    required DateTime? lastPlayedDate,
  }) {
    final writes = <Future<void>>[
      _put(highestScoreKey, highestScore),
      _put(currentRankIndexKey, currentRankIndex),
      _put(totalGamesPlayedKey, totalGamesPlayed),
      if (lastPlayedDate == null)
        _delete(lastPlayedDateKey)
      else
        _put(lastPlayedDateKey, lastPlayedDate.toIso8601String()),
      for (final entry in categoryHighScoreKeys.entries)
        _put(entry.value, highestScoresByGame[entry.key] ?? 0),
    ];
    return Future.wait(writes).then((_) {});
  }

  /// One-time copy from SharedPreferences into Hive when the box is empty.
  Future<void> migrateFromSharedPreferencesIfNeeded() async {
    if (prefsMigrated) {
      return;
    }

    final hasHiveProgress = _containsKey(currentRankIndexKey) ||
        _containsKey(lastPlayedDateKey) ||
        _containsKey(highestScoreKey) ||
        _containsKey(totalGamesPlayedKey);

    if (hasHiveProgress) {
      await _put(prefsMigratedKey, true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyTitle =
        TitleTier.tryParse(prefs.getString(legacyHighestTitleKey));
    final legacyDateRaw = prefs.getString(legacyLastEarnedDateKey);
    final legacyDate =
        legacyDateRaw == null ? null : DateTime.tryParse(legacyDateRaw);

    if (legacyTitle != null || legacyDate != null) {
      await persistProgress(
        highestScore: 0,
        highestScoresByGame: GameSessionState.emptyScoresByGame,
        currentRankIndex: legacyTitle?.index ?? 0,
        totalGamesPlayed: 0,
        lastPlayedDate: legacyDate,
      );
    }

    await _put(prefsMigratedKey, true);
  }
}

/// Provides [LocalStorageService] over the already-opened Hive box.
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(Hive.box(LocalStorageService.boxName));
});
