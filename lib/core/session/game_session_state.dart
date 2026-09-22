enum GamePhase {
  menu,
  practiceMenu,
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
    this.isPracticeMode = false,
    this.isPaused = false,
    this.pauseCount = 0,
    this.timePenaltyToken = 0,
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
  static const int pauseTimePenaltySeconds = 3;
  static const Duration timesUpDuration = Duration(seconds: 2);

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
  final bool isPracticeMode;
  final bool isPaused;
  final int pauseCount;
  final int timePenaltyToken;

  MiniGameType get currentGame => currentRunSequence[currentIndex];

  int get stageNumber => currentIndex + 1;

  int get stageCount => currentRunSequence.length;

  bool get isLastGame => currentIndex >= currentRunSequence.length - 1;

  int scoreFor(MiniGameType type) => scoresByGame[type] ?? 0;

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
    bool? isPracticeMode,
    bool? isPaused,
    int? pauseCount,
    int? timePenaltyToken,
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
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
      isPaused: isPaused ?? this.isPaused,
      pauseCount: pauseCount ?? this.pauseCount,
      timePenaltyToken: timePenaltyToken ?? this.timePenaltyToken,
    );
  }
}
