import '../session/game_session_state.dart';
import 'title_tier.dart';

class TitleProgressState {
  const TitleProgressState({
    required this.highestTitle,
    this.lastEarnedDate,
    this.lastSessionTitle,
    this.unlockedNewRank = false,
    this.isHydrated = false,
    this.highestScore = 0,
    this.highestScoresByGame = GameSessionState.emptyScoresByGame,
    this.newCategoryHighs = const <MiniGameType>{},
    this.totalGamesPlayed = 0,
    this.hasDecayed = false,
  });

  factory TitleProgressState.initial() {
    return const TitleProgressState(
      highestTitle: TitleTier.dormantMind,
    );
  }

  static const int decayDays = 7;

  final TitleTier highestTitle;
  final DateTime? lastEarnedDate;

  /// Title earned for the most recent completed core loop (ephemeral).
  final TitleTier? lastSessionTitle;

  /// True when the latest loop raised [highestTitle] (ephemeral).
  final bool unlockedNewRank;

  /// True after storage has been loaded (or mocked) at least once.
  final bool isHydrated;

  /// Personal-best full-loop score.
  final int highestScore;

  /// Personal-best score per mini-game area.
  final Map<MiniGameType, int> highestScoresByGame;

  /// Categories whose personal best was beaten on the latest recorded loop.
  final Set<MiniGameType> newCategoryHighs;

  /// Count of completed non-practice core loops.
  final int totalGamesPlayed;

  /// True when rank decay ran this session and the UI has not acknowledged it.
  final bool hasDecayed;

  /// Days remaining before the next decay, or null if no date is stored.
  int? daysLeftToDefend(DateTime now) {
    final last = lastEarnedDate;
    if (last == null) {
      return null;
    }
    final elapsed = now.difference(last).inDays;
    final remaining = decayDays - elapsed;
    if (remaining < 0) {
      return 0;
    }
    if (remaining > decayDays) {
      return decayDays;
    }
    return remaining;
  }

  int get currentRankIndex => highestTitle.index;

  int highestScoreFor(MiniGameType type) => highestScoresByGame[type] ?? 0;

  TitleProgressState copyWith({
    TitleTier? highestTitle,
    DateTime? lastEarnedDate,
    TitleTier? lastSessionTitle,
    bool? unlockedNewRank,
    bool? isHydrated,
    int? highestScore,
    Map<MiniGameType, int>? highestScoresByGame,
    Set<MiniGameType>? newCategoryHighs,
    int? totalGamesPlayed,
    bool? hasDecayed,
    bool clearLastEarnedDate = false,
    bool clearLastSessionTitle = false,
    bool clearNewCategoryHighs = false,
  }) {
    return TitleProgressState(
      highestTitle: highestTitle ?? this.highestTitle,
      lastEarnedDate: clearLastEarnedDate
          ? null
          : (lastEarnedDate ?? this.lastEarnedDate),
      lastSessionTitle: clearLastSessionTitle
          ? null
          : (lastSessionTitle ?? this.lastSessionTitle),
      unlockedNewRank: unlockedNewRank ?? this.unlockedNewRank,
      isHydrated: isHydrated ?? this.isHydrated,
      highestScore: highestScore ?? this.highestScore,
      highestScoresByGame: highestScoresByGame ?? this.highestScoresByGame,
      newCategoryHighs: clearNewCategoryHighs
          ? const <MiniGameType>{}
          : (newCategoryHighs ?? this.newCategoryHighs),
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      hasDecayed: hasDecayed ?? this.hasDecayed,
    );
  }
}
