import 'package:brainiacs_flutter/core/rank/title_progress_state.dart';
import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/features/statistics/domain/game_session_record.dart';
import 'package:brainiacs_flutter/features/statistics/domain/player_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameSessionRecord record({
    required String id,
    required int score,
    required DateTime at,
  }) {
    return GameSessionRecord(
      id: id,
      completedAt: at,
      totalScore: score,
      categoryScores: {
        MiniGameType.math: score ~/ 4,
        MiniGameType.memory: score ~/ 4,
        MiniGameType.analytical: score ~/ 4,
        MiniGameType.visual: score - 3 * (score ~/ 4),
      },
    );
  }

  TitleProgressState progress({
    int gamesPlayed = 0,
    int highestScore = 0,
  }) {
    return TitleProgressState(
      highestTitle: TitleTier.dormantMind,
      totalGamesPlayed: gamesPlayed,
      highestScore: highestScore,
    );
  }

  test('average uses last 10 of 12 sessions', () {
    final history = [
      for (var i = 1; i <= 12; i++)
        record(
          id: '$i',
          score: i * 100,
          at: DateTime(2026, 1, i),
        ),
    ];

    final stats = PlayerStatistics.compute(
      progress: progress(gamesPlayed: 12, highestScore: 1200),
      history: history,
    );

    // Last 10 scores: 300..1200 → sum = 7500, avg = 750
    expect(stats.averageScore, 750);
    expect(stats.latestScore, 1200);
    expect(stats.recentSessions, hasLength(10));
    expect(stats.recentSessions.first.totalScore, 300);
    expect(stats.recentSessions.last.totalScore, 1200);
  });

  test('average uses all sessions when fewer than 10', () {
    final history = [
      record(id: 'a', score: 100, at: DateTime(2026, 1, 1)),
      record(id: 'b', score: 200, at: DateTime(2026, 1, 2)),
      record(id: 'c', score: 300, at: DateTime(2026, 1, 3)),
    ];

    final stats = PlayerStatistics.compute(
      progress: progress(gamesPlayed: 3),
      history: history,
    );

    expect(stats.averageScore, 200);
    expect(stats.latestScore, 300);
    expect(stats.recentSessions, hasLength(3));
  });

  test('empty history yields null latest and average', () {
    final stats = PlayerStatistics.compute(
      progress: progress(),
      history: const [],
    );

    expect(stats.latestScore, isNull);
    expect(stats.averageScore, isNull);
    expect(stats.recentSessions, isEmpty);
    expect(stats.hasLegacyProgressOnly, isFalse);
  });

  test('latest picks newest by completedAt regardless of list order', () {
    final history = [
      record(id: 'new', score: 900, at: DateTime(2026, 3, 1)),
      record(id: 'old', score: 100, at: DateTime(2026, 1, 1)),
      record(id: 'mid', score: 500, at: DateTime(2026, 2, 1)),
    ];

    final stats = PlayerStatistics.compute(
      progress: progress(gamesPlayed: 3, highestScore: 900),
      history: history,
    );

    expect(stats.latestScore, 900);
    expect(stats.recentSessions.map((r) => r.id).toList(), ['old', 'mid', 'new']);
  });

  test('hasLegacyProgressOnly when games played but history empty', () {
    final stats = PlayerStatistics.compute(
      progress: progress(gamesPlayed: 5, highestScore: 4500),
      history: const [],
    );

    expect(stats.hasLegacyProgressOnly, isTrue);
    expect(stats.gamesPlayed, 5);
    expect(stats.personalBest, 4500);
    expect(stats.latestScore, isNull);
    expect(stats.averageScore, isNull);
  });

  test('average does not use personal best when history exists', () {
    final stats = PlayerStatistics.compute(
      progress: progress(gamesPlayed: 2, highestScore: 15000),
      history: [
        record(id: '1', score: 100, at: DateTime(2026, 1, 1)),
        record(id: '2', score: 200, at: DateTime(2026, 1, 2)),
      ],
    );

    expect(stats.personalBest, 15000);
    expect(stats.averageScore, 150);
  });
}
