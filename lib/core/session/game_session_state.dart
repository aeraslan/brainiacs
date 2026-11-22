enum GamePhase {
  menu,
  practiceMenu,
  myProgress,
  settings,
  tutorial,
  countdown,
  playing,
  timesUp,
  scoreScreen,
}

enum MiniGameType { math, memory, analytical, visual }

/// Which Math family game fills the Math stage for this run.
enum MathGameVariant { quickMath, missingOperator }

/// Which Analytic family game fills the Analytic stage for this run.
enum AnalyticGameVariant { cubeCount, balanceLogic }

/// Which Memory family game fills the Memory stage for this run.
enum MemoryGameVariant { cardMatch, matrixRecall }

/// Which Visual family game fills the Visual stage for this run.
enum VisualGameVariant { visualSort, colorClash }

/// Why the session is currently paused (or [none] when not paused).
enum PauseOrigin { none, manual, automatic }

class GameSessionState {
  const GameSessionState({
    required this.totalScore,
    required this.timeRemaining,
    required this.phase,
    required this.currentRunSequence,
    required this.currentIndex,
    required this.scoresByGame,
    required this.mathVariant,
    required this.analyticVariant,
    required this.memoryVariant,
    required this.visualVariant,
    this.sessionId = '',
    this.isPracticeMode = false,
    this.isPaused = false,
    this.pauseCount = 0,
    this.pauseOrigin = PauseOrigin.none,
    this.timePenaltyToken = 0,
    this.lastAppliedPenaltySeconds = 0,
    this.pauseMenuRequestId = 0,
  });

  factory GameSessionState.initial() {
    return GameSessionState(
      totalScore: 0,
      timeRemaining: maxTimeLimit,
      phase: GamePhase.menu,
      currentRunSequence: defaultRunSequence,
      currentIndex: 0,
      scoresByGame: emptyScoresByGame,
      mathVariant: MathGameVariant.quickMath,
      analyticVariant: AnalyticGameVariant.cubeCount,
      memoryVariant: MemoryGameVariant.cardMatch,
      visualVariant: VisualGameVariant.visualSort,
    );
  }

  static const int maxTimeLimit = 60;
  static const Duration timesUpDuration = Duration(seconds: 2);

  /// Time deducted when resuming after [pauseNumber] manual pauses this mini-game.
  ///
  /// Pause 1 is free. From pause 2 onward the penalty is `pauseNumber + 1`
  /// seconds (2 → 3s, 3 → 4s, …).
  static int penaltyForManualPause(int pauseNumber) {
    if (pauseNumber <= 1) {
      return 0;
    }
    return pauseNumber + 1;
  }

  static const List<MiniGameType> defaultRunSequence = [
    MiniGameType.math,
    MiniGameType.memory,
    MiniGameType.analytical,
    MiniGameType.visual,
  ];

  static const Map<MiniGameType, int> emptyScoresByGame = {
    MiniGameType.math: 0,
    MiniGameType.memory: 0,
    MiniGameType.analytical: 0,
    MiniGameType.visual: 0,
  };

  final int totalScore;
  final int timeRemaining;
  final GamePhase phase;
  final List<MiniGameType> currentRunSequence;
  final int currentIndex;
  final Map<MiniGameType, int> scoresByGame;
  final MathGameVariant mathVariant;
  final AnalyticGameVariant analyticVariant;
  final MemoryGameVariant memoryVariant;
  final VisualGameVariant visualVariant;

  /// Unique id for a New Game run; empty for practice / menu.
  final String sessionId;
  final bool isPracticeMode;
  final bool isPaused;

  /// Manual pauses opened during the current mini-game (not automatic).
  final int pauseCount;
  final PauseOrigin pauseOrigin;
  final int timePenaltyToken;

  /// Seconds deducted by the most recent [timePenaltyToken] flash.
  final int lastAppliedPenaltySeconds;

  /// Bumped when the pause menu should open (manual or automatic).
  final int pauseMenuRequestId;

  MiniGameType get currentGame => currentRunSequence[currentIndex];

  int get stageNumber => currentIndex + 1;

  int get stageCount => currentRunSequence.length;

  bool get isLastGame => currentIndex >= currentRunSequence.length - 1;

  int scoreFor(MiniGameType type) => scoresByGame[type] ?? 0;

  /// Pending Resume penalty for the current pause (0 when free or automatic).
  int get pendingResumePenaltySeconds {
    if (!isPaused) {
      return 0;
    }
    if (pauseOrigin != PauseOrigin.manual) {
      return 0;
    }
    return penaltyForManualPause(pauseCount);
  }

  GameSessionState copyWith({
    int? totalScore,
    int? timeRemaining,
    GamePhase? phase,
    List<MiniGameType>? currentRunSequence,
    int? currentIndex,
    Map<MiniGameType, int>? scoresByGame,
    MathGameVariant? mathVariant,
    AnalyticGameVariant? analyticVariant,
    MemoryGameVariant? memoryVariant,
    VisualGameVariant? visualVariant,
    String? sessionId,
    bool? isPracticeMode,
    bool? isPaused,
    int? pauseCount,
    PauseOrigin? pauseOrigin,
    int? timePenaltyToken,
    int? lastAppliedPenaltySeconds,
    int? pauseMenuRequestId,
  }) {
    return GameSessionState(
      totalScore: totalScore ?? this.totalScore,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      phase: phase ?? this.phase,
      currentRunSequence: currentRunSequence ?? this.currentRunSequence,
      currentIndex: currentIndex ?? this.currentIndex,
      scoresByGame: scoresByGame ?? this.scoresByGame,
      mathVariant: mathVariant ?? this.mathVariant,
      analyticVariant: analyticVariant ?? this.analyticVariant,
      memoryVariant: memoryVariant ?? this.memoryVariant,
      visualVariant: visualVariant ?? this.visualVariant,
      sessionId: sessionId ?? this.sessionId,
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
      isPaused: isPaused ?? this.isPaused,
      pauseCount: pauseCount ?? this.pauseCount,
      pauseOrigin: pauseOrigin ?? this.pauseOrigin,
      timePenaltyToken: timePenaltyToken ?? this.timePenaltyToken,
      lastAppliedPenaltySeconds:
          lastAppliedPenaltySeconds ?? this.lastAppliedPenaltySeconds,
      pauseMenuRequestId: pauseMenuRequestId ?? this.pauseMenuRequestId,
    );
  }
}
