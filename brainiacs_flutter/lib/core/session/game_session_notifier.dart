import 'dart:async';

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
    state = GameSessionState(
      totalScore: 0,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.tutorial,
      currentRunSequence: GameSessionState.defaultRunSequence,
      currentIndex: 0,
      scoresByGame: Map<MiniGameType, int>.from(
        GameSessionState.emptyScoresByGame,
      ),
    );
  }

  void beginPlaying() {
    if (state.phase != GamePhase.tutorial) {
      return;
    }

    _cancelTimer();
    state = state.copyWith(
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.playing,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void nextGame() {
    _cancelTimer();
    if (state.isLastGame) {
      endRun();
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.tutorial,
    );
  }

  void endRun() {
    _cancelTimer();
    state = state.copyWith(phase: GamePhase.scoreScreen);
  }

  void addScore(int delta) {
    if (state.phase != GamePhase.playing) {
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
    endRun();
  }

  void _onTick() {
    if (state.phase != GamePhase.playing) {
      _cancelTimer();
      return;
    }

    final nextTime = state.timeRemaining - 1;
    if (nextTime <= 0) {
      _cancelTimer();
      state = state.copyWith(timeRemaining: 0, phase: GamePhase.timesUp);
      _timer = Timer(GameSessionState.timesUpDuration, _afterTimesUp);
      return;
    }

    state = state.copyWith(timeRemaining: nextTime);
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
