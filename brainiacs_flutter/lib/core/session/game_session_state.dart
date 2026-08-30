enum GamePhase { menu, tutorial, playing, timesUp, scoreScreen }

enum MiniGameType { math, memory, analytical, visual }

class GameSessionState {
  const GameSessionState({
    required this.totalScore,
    required this.timeRemaining,
    required this.phase,
    required this.currentRunSequence,
    required this.currentIndex,
  });

  factory GameSessionState.initial() {
    return const GameSessionState(
      totalScore: 0,
      timeRemaining: maxTimeLimit,
      phase: GamePhase.menu,
      currentRunSequence: defaultRunSequence,
      currentIndex: 0,
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

  final int totalScore;
  final int timeRemaining;
  final GamePhase phase;
  final List<MiniGameType> currentRunSequence;
  final int currentIndex;

  MiniGameType get currentGame => currentRunSequence[currentIndex];

  int get stageNumber => currentIndex + 1;

  int get stageCount => currentRunSequence.length;

  bool get isLastGame => currentIndex >= currentRunSequence.length - 1;

  GameSessionState copyWith({
    int? totalScore,
    int? timeRemaining,
    GamePhase? phase,
    List<MiniGameType>? currentRunSequence,
    int? currentIndex,
  }) {
    return GameSessionState(
      totalScore: totalScore ?? this.totalScore,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      phase: phase ?? this.phase,
      currentRunSequence: currentRunSequence ?? this.currentRunSequence,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
