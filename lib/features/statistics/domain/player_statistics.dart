import '../../../core/rank/title_progress_state.dart';
import '../../../core/session/game_session_state.dart';
import 'game_session_record.dart';

/// Derived player stats for the My Progress dashboard.
class PlayerStatistics {
  const PlayerStatistics({
    required this.gamesPlayed,
    required this.personalBest,
    required this.latestScore,
    required this.averageScore,
    required this.categoryBests,
    required this.recentSessions,
    required this.hasLegacyProgressOnly,
  });

  /// Lifetime completed New Game sessions from persistent progress.
  final int gamesPlayed;

  /// Highest full-session score from persistent progress.
  final int personalBest;

  /// Most recent completed session score, or null when no history exists.
  final int? latestScore;

  /// Rounded average of up to the last 10 completed sessions, or null.
  final int? averageScore;

  /// Personal-best score per category from persistent progress.
  final Map<MiniGameType, int> categoryBests;

  /// Up to 10 most recent sessions, oldest → newest.
  final List<GameSessionRecord> recentSessions;

  /// True when the player has aggregate progress but no session history yet.
  final bool hasLegacyProgressOnly;

  static const int averageWindow = 10;
  static const int chartWindow = 10;

  factory PlayerStatistics.compute({
    required TitleProgressState progress,
    required List<GameSessionRecord> history,
  }) {
    final sorted = List<GameSessionRecord>.from(history)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final recent = sorted.length <= chartWindow
        ? sorted
        : sorted.sublist(sorted.length - chartWindow);

    final int? latest =
        sorted.isEmpty ? null : sorted.last.totalScore;

    final int? average;
    if (sorted.isEmpty) {
      average = null;
    } else {
      final window = sorted.length <= averageWindow
          ? sorted
          : sorted.sublist(sorted.length - averageWindow);
      final sum = window.fold<int>(0, (acc, r) => acc + r.totalScore);
      average = (sum / window.length).round();
    }

    return PlayerStatistics(
      gamesPlayed: progress.totalGamesPlayed,
      personalBest: progress.highestScore,
      latestScore: latest,
      averageScore: average,
      categoryBests: Map<MiniGameType, int>.from(progress.highestScoresByGame),
      recentSessions: List<GameSessionRecord>.unmodifiable(recent),
      hasLegacyProgressOnly:
          progress.totalGamesPlayed > 0 && sorted.isEmpty,
    );
  }
}
