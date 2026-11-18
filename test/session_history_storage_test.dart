import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/features/statistics/domain/game_session_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> sampleRecord({
    required String id,
    int totalScore = 1000,
    DateTime? completedAt,
  }) {
    return GameSessionRecord(
      id: id,
      completedAt: completedAt ?? DateTime(2026, 11, 1),
      totalScore: totalScore,
      categoryScores: {
        MiniGameType.math: 250,
        MiniGameType.memory: 250,
        MiniGameType.analytical: 250,
        MiniGameType.visual: 250,
      },
      mathVariant: MathGameVariant.quickMath,
      memoryVariant: MemoryGameVariant.cardMatch,
      analyticVariant: AnalyticGameVariant.cubeCount,
      visualVariant: VisualGameVariant.visualSort,
    ).toMap();
  }

  test('appendSessionRecord saves and retrieves records', () async {
    final storage = LocalStorageService.memory();
    await storage.appendSessionRecord(sampleRecord(id: 'a', totalScore: 1200));
    await storage.appendSessionRecord(sampleRecord(id: 'b', totalScore: 1800));

    final raw = storage.rawSessionHistory;
    expect(raw, hasLength(2));
    expect(raw[0]['id'], 'a');
    expect(raw[1]['id'], 'b');

    final parsed = GameSessionRecord.tryParse(raw[1]);
    expect(parsed, isNotNull);
    expect(parsed!.totalScore, 1800);
    expect(parsed.mathVariant, MathGameVariant.quickMath);
  });

  test('appendSessionRecord preserves existing progress keys', () async {
    final storage = LocalStorageService.memory({
      LocalStorageService.highestScoreKey: 9000,
      LocalStorageService.totalGamesPlayedKey: 7,
      LocalStorageService.currentRankIndexKey: 3,
      LocalStorageService.highestScoreMathKey: 2200,
    });

    await storage.appendSessionRecord(sampleRecord(id: 'run-1'));

    expect(storage.highestScore, 9000);
    expect(storage.totalGamesPlayed, 7);
    expect(storage.currentRankIndex, 3);
    expect(storage.highestScoreFor(MiniGameType.math), 2200);
    expect(storage.rawSessionHistory, hasLength(1));
  });

  test('appendSessionRecord enforces 100-session cap', () async {
    final storage = LocalStorageService.memory();
    for (var i = 0; i < 101; i++) {
      await storage.appendSessionRecord(
        sampleRecord(
          id: 'id-$i',
          totalScore: i,
          completedAt: DateTime(2026, 1, 1).add(Duration(days: i)),
        ),
      );
    }

    final raw = storage.rawSessionHistory;
    expect(raw, hasLength(LocalStorageService.maxSessionHistory));
    expect(raw.first['id'], 'id-1');
    expect(raw.last['id'], 'id-100');
  });

  test('appendSessionRecord ignores duplicate ids', () async {
    final storage = LocalStorageService.memory();
    await storage.appendSessionRecord(sampleRecord(id: 'dup', totalScore: 500));
    await storage.appendSessionRecord(sampleRecord(id: 'dup', totalScore: 999));

    expect(storage.rawSessionHistory, hasLength(1));
    expect(storage.rawSessionHistory.single['totalScore'], 500);
  });

  test('rawSessionHistory skips non-map entries', () {
    final storage = LocalStorageService.memory({
      LocalStorageService.sessionHistoryKey: [
        'bad',
        42,
        sampleRecord(id: 'good'),
        null,
      ],
    });

    expect(storage.rawSessionHistory, hasLength(1));
    expect(storage.rawSessionHistory.single['id'], 'good');
  });

  test('GameSessionRecord.tryParse handles malformed maps', () {
    expect(GameSessionRecord.tryParse(null), isNull);
    expect(GameSessionRecord.tryParse('nope'), isNull);
    expect(GameSessionRecord.tryParse({'id': ''}), isNull);
    expect(
      GameSessionRecord.tryParse({
        'id': 'x',
        'completedAt': 'not-a-date',
        'totalScore': 10,
      }),
      isNull,
    );
    expect(
      GameSessionRecord.tryParse({
        'id': 'x',
        'completedAt': DateTime(2026, 1, 1).toIso8601String(),
        'totalScore': 'bad',
      }),
      isNull,
    );

    final partial = GameSessionRecord.tryParse({
      'id': 'ok',
      'completedAt': DateTime(2026, 2, 2).toIso8601String(),
      'totalScore': 42,
      'mathVariant': 'unknownVariant',
      'categoryScores': {'math': 10},
    });
    expect(partial, isNotNull);
    expect(partial!.mathVariant, isNull);
    expect(partial.categoryScores[MiniGameType.math], 10);
    expect(partial.categoryScores[MiniGameType.memory], 0);
  });
}
