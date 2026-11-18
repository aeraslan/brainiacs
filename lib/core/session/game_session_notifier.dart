import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/statistics/application/session_history_notifier.dart';
import '../../features/statistics/domain/game_session_record.dart';
import '../audio/audio_controller_provider.dart';
import '../rank/title_progress_notifier.dart';
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
    ref.read(titleProgressProvider.notifier).applyDecayIfNeeded();
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
      sessionId: DateTime.now().microsecondsSinceEpoch.toString(),
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
    ref.read(audioControllerProvider.notifier).playMenuBGM();
  }

  void openMyProgress() {
    if (state.phase != GamePhase.menu) {
      return;
    }
    state = state.copyWith(phase: GamePhase.myProgress);
  }

  void closeMyProgress() {
    if (state.phase != GamePhase.myProgress) {
      return;
    }
    state = state.copyWith(phase: GamePhase.menu);
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
      pauseCount: 0,
    );
    ref.read(audioControllerProvider.notifier).playGameBGM();
    _startPeriodicTimer();
  }

  void pauseGame() {
    if (state.phase != GamePhase.playing || state.isPaused) {
      return;
    }
    _cancelTimer();
    state = state.copyWith(
      isPaused: true,
      pauseCount: state.pauseCount + 1,
    );
  }

  void resumeGame() {
    if (state.phase != GamePhase.playing || !state.isPaused) {
      return;
    }

    final applyPenalty = state.pauseCount >= 2;
    if (applyPenalty) {
      final previousTime = state.timeRemaining;
      final nextTime = previousTime -
          GameSessionState.pauseTimePenaltySeconds;
      if (nextTime <= 0) {
        _cancelTimer();
        state = state.copyWith(
          timeRemaining: 0,
          phase: GamePhase.timesUp,
          isPaused: false,
          timePenaltyToken: state.timePenaltyToken + 1,
        );
        // Penalty skipped the 3s warning window — still fire the alarm.
        ref.read(audioControllerProvider.notifier).playTimeUpAlarm();
        _timer = Timer(GameSessionState.timesUpDuration, _afterTimesUp);
        return;
      }

      state = state.copyWith(
        isPaused: false,
        timeRemaining: nextTime,
        timePenaltyToken: state.timePenaltyToken + 1,
      );
      if (previousTime > 3 && nextTime <= 3) {
        ref.read(audioControllerProvider.notifier).playTimeUpAlarm();
      }
      _startPeriodicTimer();
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
      _finishRun(completed: true);
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.tutorial,
      isPaused: false,
      pauseCount: 0,
    );
  }

  void endRun() {
    _finishRun(completed: true);
  }

  void _finishRun({required bool completed}) {
    _cancelTimer();
    if (!state.isPracticeMode) {
      ref.read(titleProgressProvider.notifier).recordLoopScore(
            totalScore: state.totalScore,
            scoresByGame: state.scoresByGame,
          );
      if (completed && state.sessionId.isNotEmpty) {
        ref.read(sessionHistoryProvider.notifier).record(
              GameSessionRecord(
                id: state.sessionId,
                completedAt: DateTime.now(),
                totalScore: state.totalScore,
                categoryScores: Map<MiniGameType, int>.from(state.scoresByGame),
                mathVariant: state.mathVariant,
                memoryVariant: state.memoryVariant,
                analyticVariant: state.analyticVariant,
                visualVariant: state.visualVariant,
              ),
            );
      }
    }
    state = state.copyWith(phase: GamePhase.scoreScreen, isPaused: false);
    ref.read(audioControllerProvider.notifier).playResultBGM();
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
    ref.read(audioControllerProvider.notifier).playMenuBGM();
  }

  void endSessionEarly() {
    if (state.phase != GamePhase.playing) {
      return;
    }
    if (state.isPracticeMode) {
      openPracticeMenu();
      return;
    }
    _finishRun(completed: false);
  }

  void _onTick() {
    if (state.phase != GamePhase.playing || state.isPaused) {
      _cancelTimer();
      return;
    }

    final nextTime = state.timeRemaining - 1;
    if (nextTime == 3) {
      ref.read(audioControllerProvider.notifier).playTimeUpAlarm();
    }
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
