enum GamePhase { menu, tutorial, playing, timesUp, scoreScreen }

enum MiniGameType { math, memory, analytical, visual }

class GameSessionState {
  const GameSessionState({
    required this.totalScore,
    required this.timeRemaining,
    required this.phase,
    required this.currentRunSequence,
    required this.currentIndex,
    required this.scoresByGame,
  });

  factory GameSessionState.initial() {
    return GameSessionState(
      totalScore: 0,
      timeRemaining: maxTimeLimit,
      phase: GamePhase.menu,
      currentRunSequence: defaultRunSequence,
      currentIndex: 0,
      scoresByGame: emptyScoresByGame,
    );
  }

  static const int maxTimeLimit = 60;
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
  }) {
    return GameSessionState(
      totalScore: totalScore ?? this.totalScore,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      phase: phase ?? this.phase,
      currentRunSequence: currentRunSequence ?? this.currentRunSequence,
      currentIndex: currentIndex ?? this.currentIndex,
      scoresByGame: scoresByGame ?? this.scoresByGame,
    );
  }
}
