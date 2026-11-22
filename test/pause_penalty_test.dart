import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';

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

  GameSessionNotifier startPlaying() {
    final notifier = container.read(gameSessionProvider.notifier);
    notifier.startPractice(type: MiniGameType.math);
    notifier.beginPlaying();
    return notifier;
  }

  test('penaltyForManualPause schedule is 0,3,4,5,6…', () {
    expect(GameSessionState.penaltyForManualPause(0), 0);
    expect(GameSessionState.penaltyForManualPause(1), 0);
    expect(GameSessionState.penaltyForManualPause(2), 3);
    expect(GameSessionState.penaltyForManualPause(3), 4);
    expect(GameSessionState.penaltyForManualPause(4), 5);
    expect(GameSessionState.penaltyForManualPause(5), 6);
    expect(GameSessionState.penaltyForManualPause(6), 7);
  });

  test('first manual pause has 0-second penalty', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      expect(container.read(gameSessionProvider).timeRemaining, 60);

      notifier.pauseGame();
      expect(container.read(gameSessionProvider).pauseCount, 1);
      expect(container.read(gameSessionProvider).pauseOrigin, PauseOrigin.manual);

      notifier.resumeGame();
      expect(container.read(gameSessionProvider).isPaused, isFalse);
      expect(container.read(gameSessionProvider).timeRemaining, 60);
      expect(container.read(gameSessionProvider).lastAppliedPenaltySeconds, 0);
    });
  });

  test('second through fifth manual pauses deduct 3,4,5,6 seconds', () {
    fakeAsync((async) {
      final notifier = startPlaying();

      // Pause 1 — free
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 60);

      // Pause 2 — 3s
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 57);
      expect(container.read(gameSessionProvider).lastAppliedPenaltySeconds, 3);

      // Pause 3 — 4s
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 53);
      expect(container.read(gameSessionProvider).lastAppliedPenaltySeconds, 4);

      // Pause 4 — 5s
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 48);
      expect(container.read(gameSessionProvider).lastAppliedPenaltySeconds, 5);

      // Pause 5 — 6s
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 42);
      expect(container.read(gameSessionProvider).lastAppliedPenaltySeconds, 6);
    });
  });

  test('repeated resumeGame does not apply duplicate penalties', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseGame();
      notifier.resumeGame();
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 57);

      notifier.resumeGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 57);
      expect(container.read(gameSessionProvider).isPaused, isFalse);
    });
  });

  test('quitting without resume does not apply pending penalty', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseGame();
      notifier.pauseGame(); // no-op while paused
      expect(container.read(gameSessionProvider).pauseCount, 1);

      // Second pause after resume so a pending penalty exists
      notifier.resumeGame();
      notifier.pauseGame();
      expect(container.read(gameSessionProvider).pauseCount, 2);
      expect(container.read(gameSessionProvider).pendingResumePenaltySeconds, 3);
      expect(container.read(gameSessionProvider).timeRemaining, 60);

      notifier.resetToMenu();
      expect(container.read(gameSessionProvider).phase, GamePhase.menu);
    });
  });

  test('endSessionEarly while paused skips pending penalty', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseGame();
      notifier.resumeGame();
      notifier.pauseGame();
      expect(container.read(gameSessionProvider).pendingResumePenaltySeconds, 3);

      notifier.endSessionEarly();
      expect(container.read(gameSessionProvider).phase, GamePhase.practiceMenu);
    });
  });

  test('penalty that consumes all remaining time goes to timesUp', () {
    fakeAsync((async) {
      final notifier = startPlaying();

      // Burn time down to 3 seconds
      async.elapse(const Duration(seconds: 57));
      expect(container.read(gameSessionProvider).timeRemaining, 3);

      notifier.pauseGame(); // free
      notifier.resumeGame();
      notifier.pauseGame(); // 3s penalty
      notifier.resumeGame();

      final state = container.read(gameSessionProvider);
      expect(state.phase, GamePhase.timesUp);
      expect(state.timeRemaining, 0);
      expect(state.isPaused, isFalse);
      expect(state.lastAppliedPenaltySeconds, 3);

      async.elapse(GameSessionState.timesUpDuration);
      expect(container.read(gameSessionProvider).phase, GamePhase.practiceMenu);
    });
  });

  test('beginPlaying resets pause counter for next mini-game', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseGame();
      notifier.resumeGame();
      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).pauseCount, 2);

      notifier.nextGame(); // practice → practiceMenu
      notifier.startPractice(type: MiniGameType.visual);
      notifier.beginPlaying();

      final state = container.read(gameSessionProvider);
      expect(state.pauseCount, 0);
      expect(state.pauseOrigin, PauseOrigin.none);
      expect(state.isPaused, isFalse);
    });
  });

  test('automatic background pause does not increment pauseCount', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseForBackground();

      final state = container.read(gameSessionProvider);
      expect(state.isPaused, isTrue);
      expect(state.pauseCount, 0);
      expect(state.pauseOrigin, PauseOrigin.automatic);
      expect(state.pauseMenuRequestId, greaterThan(0));

      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 60);
      expect(container.read(gameSessionProvider).lastAppliedPenaltySeconds, 0);
    });
  });

  test('repeated background pause does not create duplicate pause events', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseForBackground();
      final requestId = container.read(gameSessionProvider).pauseMenuRequestId;

      notifier.pauseForBackground();
      notifier.pauseForBackground();
      expect(container.read(gameSessionProvider).pauseCount, 0);
      expect(container.read(gameSessionProvider).pauseMenuRequestId, requestId);
    });
  });

  test('backgrounding a manual pause preserves pending penalty', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseGame();
      notifier.resumeGame();
      notifier.pauseGame();
      expect(container.read(gameSessionProvider).pendingResumePenaltySeconds, 3);

      final requestId = container.read(gameSessionProvider).pauseMenuRequestId;
      notifier.pauseForBackground();

      final state = container.read(gameSessionProvider);
      expect(state.pauseOrigin, PauseOrigin.manual);
      expect(state.pauseCount, 2);
      expect(state.pendingResumePenaltySeconds, 3);
      expect(state.pauseMenuRequestId, requestId);

      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 57);
    });
  });

  test('first free manual pause is not consumed by automatic pause', () {
    fakeAsync((async) {
      final notifier = startPlaying();
      notifier.pauseForBackground();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).pauseCount, 0);

      notifier.pauseGame();
      notifier.resumeGame();
      expect(container.read(gameSessionProvider).timeRemaining, 60);
      expect(container.read(gameSessionProvider).pauseCount, 1);
    });
  });
}
