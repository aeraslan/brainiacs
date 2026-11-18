import '../../../core/session/game_session_state.dart';

/// One completed New Game (full 4-stage) session for local history.
class GameSessionRecord {
  const GameSessionRecord({
    required this.id,
    required this.completedAt,
    required this.totalScore,
    required this.categoryScores,
    this.mathVariant,
    this.memoryVariant,
    this.analyticVariant,
    this.visualVariant,
  });

  final String id;
  final DateTime completedAt;
  final int totalScore;
  final Map<MiniGameType, int> categoryScores;
  final MathGameVariant? mathVariant;
  final MemoryGameVariant? memoryVariant;
  final AnalyticGameVariant? analyticVariant;
  final VisualGameVariant? visualVariant;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'totalScore': totalScore,
      'categoryScores': {
        for (final type in MiniGameType.values)
          type.name: categoryScores[type] ?? 0,
      },
      if (mathVariant != null) 'mathVariant': mathVariant!.name,
      if (memoryVariant != null) 'memoryVariant': memoryVariant!.name,
      if (analyticVariant != null) 'analyticVariant': analyticVariant!.name,
      if (visualVariant != null) 'visualVariant': visualVariant!.name,
    };
  }

  /// Returns null when required fields are missing or malformed.
  static GameSessionRecord? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }

    final map = Map<Object?, Object?>.from(raw);
    final id = map['id'];
    if (id is! String || id.isEmpty) {
      return null;
    }

    final completedAtRaw = map['completedAt'];
    if (completedAtRaw is! String || completedAtRaw.isEmpty) {
      return null;
    }
    final completedAt = DateTime.tryParse(completedAtRaw);
    if (completedAt == null) {
      return null;
    }

    final totalScoreRaw = map['totalScore'];
    final int? totalScore = switch (totalScoreRaw) {
      int value => value,
      num value => value.round(),
      _ => null,
    };
    if (totalScore == null || totalScore < 0) {
      return null;
    }

    final categoryScores = <MiniGameType, int>{
      for (final type in MiniGameType.values) type: 0,
    };
    final scoresRaw = map['categoryScores'];
    if (scoresRaw is Map) {
      for (final type in MiniGameType.values) {
        final value = scoresRaw[type.name];
        if (value is int) {
          categoryScores[type] = value < 0 ? 0 : value;
        } else if (value is num) {
          categoryScores[type] = value.round().clamp(0, 1 << 30);
        }
      }
    }

    return GameSessionRecord(
      id: id,
      completedAt: completedAt,
      totalScore: totalScore,
      categoryScores: categoryScores,
      mathVariant: _parseEnum(MathGameVariant.values, map['mathVariant']),
      memoryVariant: _parseEnum(MemoryGameVariant.values, map['memoryVariant']),
      analyticVariant:
          _parseEnum(AnalyticGameVariant.values, map['analyticVariant']),
      visualVariant: _parseEnum(VisualGameVariant.values, map['visualVariant']),
    );
  }

  static T? _parseEnum<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String || raw.isEmpty) {
      return null;
    }
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
    return null;
  }
}
