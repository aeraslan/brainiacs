import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_session_state.dart';

class GameSessionNotifier extends Notifier<GameSessionState> {
  Timer? _timer;

  @override
  GameSessionState build() {
    ref.onDispose(_cancelTimer);
    return GameSessionState.initial();
  }

  void startGame() {
    _cancelTimer();
    final rng = Random();
    final mathVariant = rng.nextBool()
        ? MathGameVariant.quickMath
        : MathGameVariant.missingOperator;
    final analyticVariant = rng.nextBool()
        ? AnalyticGameVariant.cubeCount
        : AnalyticGameVariant.balanceLogic;
    final memoryVariant = rng.nextBool()
        ? MemoryGameVariant.cardMatch
        : MemoryGameVariant.matrixRecall;
    final visualVariant = rng.nextBool()
        ? VisualGameVariant.visualSort
        : VisualGameVariant.colorClash;
    state = GameSessionState(
      totalScore: 0,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.tutorial,
      currentRunSequence: GameSessionState.defaultRunSequence,
      currentIndex: 0,
      scoresByGame: Map<MiniGameType, int>.from(
        GameSessionState.emptyScoresByGame,
      ),
      mathVariant: mathVariant,
      analyticVariant: analyticVariant,
      memoryVariant: memoryVariant,
      visualVariant: visualVariant,
    );
  }

  void openPracticeMenu() {
    _cancelTimer();
    state = GameSessionState(
      totalScore: 0,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.practiceMenu,
      currentRunSequence: GameSessionState.defaultRunSequence,
      currentIndex: 0,
      scoresByGame: Map<MiniGameType, int>.from(
        GameSessionState.emptyScoresByGame,
      ),
      mathVariant: MathGameVariant.quickMath,
      analyticVariant: AnalyticGameVariant.cubeCount,
      memoryVariant: MemoryGameVariant.cardMatch,
      visualVariant: VisualGameVariant.visualSort,
      isPracticeMode: true,
    );
  }

  void startPractice({
    required MiniGameType type,
    MathGameVariant mathVariant = MathGameVariant.quickMath,
    AnalyticGameVariant analyticVariant = AnalyticGameVariant.cubeCount,
    MemoryGameVariant memoryVariant = MemoryGameVariant.cardMatch,
    VisualGameVariant visualVariant = VisualGameVariant.visualSort,
  }) {
    _cancelTimer();
    state = GameSessionState(
      totalScore: 0,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.countdown,
      currentRunSequence: [type],
      currentIndex: 0,
      scoresByGame: Map<MiniGameType, int>.from(
        GameSessionState.emptyScoresByGame,
      ),
      mathVariant: mathVariant,
      analyticVariant: analyticVariant,
      memoryVariant: memoryVariant,
      visualVariant: visualVariant,
      isPracticeMode: true,
    );
  }

  void beginPlaying() {
    if (state.phase != GamePhase.tutorial &&
        state.phase != GamePhase.countdown) {
      return;
    }

    _cancelTimer();
    state = state.copyWith(
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.playing,
      isPaused: false,
    );
    _startPeriodicTimer();
  }

  void pauseGame() {
    if (state.phase != GamePhase.playing || state.isPaused) {
      return;
    }
    _cancelTimer();
    state = state.copyWith(isPaused: true);
  }

  void resumeGame() {
    if (state.phase != GamePhase.playing || !state.isPaused) {
      return;
    }
    state = state.copyWith(isPaused: false);
    _startPeriodicTimer();
  }

  void nextGame() {
    _cancelTimer();
    if (state.isPracticeMode) {
      openPracticeMenu();
      return;
    }

    if (state.isLastGame) {
      endRun();
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.tutorial,
      isPaused: false,
    );
  }

  void endRun() {
    _cancelTimer();
    state = state.copyWith(phase: GamePhase.scoreScreen, isPaused: false);
  }

  void addScore(int delta) {
    if (state.phase != GamePhase.playing || state.isPaused) {
      return;
    }

    final game = state.currentGame;
    final nextGameScore = (state.scoreFor(game) + delta).clamp(0, 1 << 30);
    final nextScores = Map<MiniGameType, int>.from(state.scoresByGame)
      ..[game] = nextGameScore;
    final nextTotal = nextScores.values.fold<int>(0, (sum, v) => sum + v);

    state = state.copyWith(
      scoresByGame: nextScores,
      totalScore: nextTotal < 0 ? 0 : nextTotal,
    );
  }

  void resetToMenu() {
    _cancelTimer();
    state = GameSessionState.initial();
  }

  void endSessionEarly() {
    if (state.phase != GamePhase.playing) {
      return;
    }
    if (state.isPracticeMode) {
      openPracticeMenu();
      return;
    }
    endRun();
  }

  void _onTick() {
    if (state.phase != GamePhase.playing || state.isPaused) {
      _cancelTimer();
      return;
    }

    final nextTime = state.timeRemaining - 1;
    if (nextTime <= 0) {
      _cancelTimer();
      state = state.copyWith(
        timeRemaining: 0,
        phase: GamePhase.timesUp,
        isPaused: false,
      );
      _timer = Timer(GameSessionState.timesUpDuration, _afterTimesUp);
      return;
    }

    state = state.copyWith(timeRemaining: nextTime);
  }

  void _startPeriodicTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _afterTimesUp() {
    if (state.phase != GamePhase.timesUp) {
      return;
    }
    nextGame();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

final gameSessionProvider =
    NotifierProvider<GameSessionNotifier, GameSessionState>(
      GameSessionNotifier.new,
    );
