import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('startPractice enters countdown with isPracticeMode', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startPractice(
      type: MiniGameType.memory,
      mathVariant: MathGameVariant.quickMath,
    );

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.countdown);
    expect(state.isPracticeMode, isTrue);
    expect(state.currentGame, MiniGameType.memory);
    expect(state.currentRunSequence, [MiniGameType.memory]);
  });

  test('startPractice with balanceLogic sets analyticVariant', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startPractice(
      type: MiniGameType.analytical,
      analyticVariant: AnalyticGameVariant.balanceLogic,
    );

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.countdown);
    expect(state.isPracticeMode, isTrue);
    expect(state.currentGame, MiniGameType.analytical);
    expect(state.analyticVariant, AnalyticGameVariant.balanceLogic);
  });

  test('startPractice with matrixRecall sets memoryVariant', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startPractice(
      type: MiniGameType.memory,
      memoryVariant: MemoryGameVariant.matrixRecall,
    );

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.countdown);
    expect(state.isPracticeMode, isTrue);
    expect(state.currentGame, MiniGameType.memory);
    expect(state.memoryVariant, MemoryGameVariant.matrixRecall);
  });

  test('beginPlaying after practice countdown starts the timer phase', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startPractice(type: MiniGameType.memory);
    notifier.beginPlaying();

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.playing);
    expect(state.isPracticeMode, isTrue);
  });

  test('nextGame in practice returns to practiceMenu, not scoreScreen', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startPractice(type: MiniGameType.visual);
    notifier.beginPlaying();
    notifier.nextGame();

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.practiceMenu);
    expect(state.isPracticeMode, isTrue);
    expect(state.phase, isNot(GamePhase.scoreScreen));
  });

  test('endSessionEarly in practice returns to practiceMenu', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startPractice(
      type: MiniGameType.math,
      mathVariant: MathGameVariant.missingOperator,
    );
    notifier.beginPlaying();
    notifier.endSessionEarly();

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.practiceMenu);
    expect(state.isPracticeMode, isTrue);
  });

  test('openPracticeMenu sets practiceMenu phase', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.openPracticeMenu();

    final state = container.read(gameSessionProvider);
    expect(state.phase, GamePhase.practiceMenu);
    expect(state.isPracticeMode, isTrue);
    expect(state.totalScore, 0);
  });

  test('full run nextGame still ends at scoreScreen when not practice', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.startGame();
    expect(container.read(gameSessionProvider).isPracticeMode, isFalse);

    final stageCount = container.read(gameSessionProvider).stageCount;
    for (var i = 0; i < stageCount - 1; i++) {
      notifier.nextGame();
    }
    expect(container.read(gameSessionProvider).isLastGame, isTrue);

    notifier.nextGame();
    expect(container.read(gameSessionProvider).phase, GamePhase.scoreScreen);
  });

  test('pause freezes timer; resume continues from frozen value', () {
    fakeAsync((async) {
      final notifier = container.read(gameSessionProvider.notifier);

      notifier.startPractice(type: MiniGameType.memory);
      notifier.beginPlaying();
      expect(container.read(gameSessionProvider).timeRemaining, 60);

      async.elapse(const Duration(seconds: 3));
      expect(container.read(gameSessionProvider).timeRemaining, 57);
      expect(container.read(gameSessionProvider).isPaused, isFalse);

      notifier.pauseGame();
      expect(container.read(gameSessionProvider).isPaused, isTrue);
      expect(container.read(gameSessionProvider).timeRemaining, 57);

      async.elapse(const Duration(seconds: 5));
      expect(container.read(gameSessionProvider).timeRemaining, 57);
      expect(container.read(gameSessionProvider).isPaused, isTrue);

      notifier.resumeGame();
      expect(container.read(gameSessionProvider).isPaused, isFalse);
      expect(container.read(gameSessionProvider).timeRemaining, 57);

      async.elapse(const Duration(seconds: 2));
      expect(container.read(gameSessionProvider).timeRemaining, 55);
    });
  });

  test('pauseGame and resumeGame are no-ops when not playing', () {
    final notifier = container.read(gameSessionProvider.notifier);

    notifier.pauseGame();
    expect(container.read(gameSessionProvider).isPaused, isFalse);

    notifier.resumeGame();
    expect(container.read(gameSessionProvider).isPaused, isFalse);

    notifier.openPracticeMenu();
    notifier.pauseGame();
    expect(container.read(gameSessionProvider).isPaused, isFalse);
    notifier.resumeGame();
    expect(container.read(gameSessionProvider).isPaused, isFalse);
  });

  test('addScore is ignored while paused', () {
    fakeAsync((async) {
      final notifier = container.read(gameSessionProvider.notifier);

      notifier.startPractice(type: MiniGameType.memory);
      notifier.beginPlaying();
      notifier.addScore(10);
      expect(container.read(gameSessionProvider).totalScore, 10);

      notifier.pauseGame();
      notifier.addScore(5);
      expect(container.read(gameSessionProvider).totalScore, 10);

      notifier.resumeGame();
      notifier.addScore(5);
      expect(container.read(gameSessionProvider).totalScore, 15);
    });
  });
}
