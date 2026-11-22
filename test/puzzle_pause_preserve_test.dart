import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/features/analytical/presentation/balance_logic_notifier.dart';
import 'package:brainiacs_flutter/features/analytical/presentation/cube_count_notifier.dart';
import 'package:brainiacs_flutter/features/math/presentation/missing_operator_notifier.dart';
import 'package:brainiacs_flutter/features/math/presentation/quick_math_notifier.dart';
import 'package:brainiacs_flutter/features/memory/presentation/card_match_notifier.dart';
import 'package:brainiacs_flutter/features/memory/presentation/matrix_recall_notifier.dart';
import 'package:brainiacs_flutter/features/visual/presentation/color_clash_notifier.dart';
import 'package:brainiacs_flutter/features/visual/presentation/visual_sort_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorageService.memory()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  void beginPractice(MiniGameType type) {
    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(type: type);
    session.beginPlaying();
  }

  test('Quick Math pause/resume keeps the same equation', () {
    beginPractice(MiniGameType.math);
    final math = container.read(quickMathProvider.notifier);
    math.reset();
    final before = container.read(quickMathProvider).equation;

    container.read(gameSessionProvider.notifier).pauseGame();
    container.read(gameSessionProvider.notifier).resumeGame();

    expect(
      container.read(quickMathProvider).equation.displayText,
      before.displayText,
    );
    expect(
      container.read(quickMathProvider).equation.correctAnswer,
      before.correctAnswer,
    );
  });

  test('Missing Operator pause/resume keeps the same equation', () {
    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.math,
      mathVariant: MathGameVariant.missingOperator,
    );
    session.beginPlaying();

    final notifier = container.read(missingOperatorProvider.notifier);
    notifier.reset();
    final before = container.read(missingOperatorProvider).equation;

    session.pauseGame();
    session.resumeGame();

    expect(
      container.read(missingOperatorProvider).equation.identityKey,
      before.identityKey,
    );
    expect(
      container.read(missingOperatorProvider).equation.correctOperator,
      before.correctOperator,
    );
  });

  test('Card Match pause/resume keeps board and freezes memorize', () {
    fakeAsync((async) {
      final session = container.read(gameSessionProvider.notifier);
      session.startPractice(
        type: MiniGameType.memory,
        memoryVariant: MemoryGameVariant.cardMatch,
      );
      session.beginPlaying();

      final cards = container.read(cardMatchProvider.notifier);
      cards.reset();
      expect(container.read(cardMatchProvider).phase, CardMatchPhase.memorize);
      final beforeCards = container.read(cardMatchProvider).cards;

      session.pauseGame();
      async.elapse(const Duration(seconds: 5));
      expect(container.read(cardMatchProvider).phase, CardMatchPhase.memorize);

      session.resumeGame();
      expect(container.read(cardMatchProvider).cards, beforeCards);
      expect(container.read(cardMatchProvider).phase, CardMatchPhase.memorize);

      async.elapse(CardMatchState.memorizeDuration);
      expect(container.read(cardMatchProvider).phase, CardMatchPhase.play);
    });
  });

  test('Matrix Recall pause/resume keeps sequence and progress', () {
    fakeAsync((async) {
      final session = container.read(gameSessionProvider.notifier);
      session.startPractice(
        type: MiniGameType.memory,
        memoryVariant: MemoryGameVariant.matrixRecall,
      );
      session.beginPlaying();

      final recall = container.read(matrixRecallProvider.notifier);
      recall.reset();
      async.elapse(const Duration(milliseconds: 100));

      final before = container.read(matrixRecallProvider);
      session.pauseGame();
      async.elapse(const Duration(seconds: 2));
      session.resumeGame();

      final after = container.read(matrixRecallProvider);
      expect(after.sequence, before.sequence);
      expect(after.sequenceLength, before.sequenceLength);
      expect(after.currentSequenceIndex, before.currentSequenceIndex);
    });
  });

  test('Cube Count pause/resume keeps the same puzzle', () {
    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.analytical,
      analyticVariant: AnalyticGameVariant.cubeCount,
    );
    session.beginPlaying();

    final cube = container.read(cubeCountProvider.notifier);
    cube.reset();
    final before = container.read(cubeCountProvider);

    session.pauseGame();
    session.resumeGame();

    final after = container.read(cubeCountProvider);
    expect(after.expectedTotal, before.expectedTotal);
    expect(after.currentLevel, before.currentLevel);
    expect(after.currentGrid.heights, before.currentGrid.heights);
  });

  test('Balance Logic pause/resume keeps the same puzzle', () {
    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.analytical,
      analyticVariant: AnalyticGameVariant.balanceLogic,
    );
    session.beginPlaying();

    final balance = container.read(balanceLogicProvider.notifier);
    balance.reset();
    final before = container.read(balanceLogicProvider).puzzle;

    session.pauseGame();
    session.resumeGame();

    final after = container.read(balanceLogicProvider).puzzle;
    expect(after.correctObjectId, before.correctObjectId);
    expect(after.identityKey, before.identityKey);
  });

  test('Color Clash pause/resume keeps the same round', () {
    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.visual,
      visualVariant: VisualGameVariant.colorClash,
    );
    session.beginPlaying();

    final clash = container.read(colorClashProvider.notifier);
    clash.reset();
    final before = container.read(colorClashProvider).round;

    session.pauseGame();
    session.resumeGame();

    final after = container.read(colorClashProvider).round;
    expect(after.correctIdentityId, before.correctIdentityId);
    expect(after.identityKey, before.identityKey);
    expect(after.rule, before.rule);
  });

  test('Visual Sort pause/resume keeps level and progress', () {
    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.visual,
      visualVariant: VisualGameVariant.visualSort,
    );
    session.beginPlaying();

    final sort = container.read(visualSortProvider.notifier);
    sort.reset();
    // Force a board without a playfield by reading initial state
    final before = container.read(visualSortProvider);

    session.pauseGame();
    session.resumeGame();

    final after = container.read(visualSortProvider);
    expect(after.currentLevel, before.currentLevel);
    expect(after.nextExpectedIndex, before.nextExpectedIndex);
    expect(after.boardGeneration, before.boardGeneration);
  });
}
