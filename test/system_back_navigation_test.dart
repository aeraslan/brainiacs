import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/features/statistics/application/session_history_notifier.dart';
import 'package:brainiacs_flutter/shared/widgets/gameplay_pause_host.dart';
import 'package:brainiacs_flutter/shared/widgets/pause_menu_dialog.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors [HomeShell] Android Back handling without pumping the full app shell
/// (menu animations leave pending timers under pumpAndSettle).
void handleSystemBack(GameSessionNotifier notifier, GameSessionState state) {
  switch (state.phase) {
    case GamePhase.menu:
      break;
    case GamePhase.practiceMenu:
    case GamePhase.tutorial:
      notifier.resetToMenu();
    case GamePhase.countdown:
      notifier.openPracticeMenu();
    case GamePhase.settings:
      notifier.closeSettings();
    case GamePhase.myProgress:
      notifier.closeMyProgress();
    case GamePhase.playing:
      notifier.pauseGame();
    case GamePhase.timesUp:
      break;
    case GamePhase.scoreScreen:
      notifier.resetToMenu();
  }
}

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

  test('Back during gameplay is one manual pause', () {
    fakeAsync((async) {
      final notifier = container.read(gameSessionProvider.notifier);
      notifier.startPractice(type: MiniGameType.math);
      notifier.beginPlaying();

      handleSystemBack(notifier, container.read(gameSessionProvider));
      final state = container.read(gameSessionProvider);
      expect(state.isPaused, isTrue);
      expect(state.pauseCount, 1);
      expect(state.pauseOrigin, PauseOrigin.manual);
      expect(state.pauseMenuRequestId, greaterThan(0));

      handleSystemBack(notifier, container.read(gameSessionProvider));
      expect(container.read(gameSessionProvider).pauseCount, 1);
    });
  });

  test('Back from practice menu returns to main menu', () {
    final notifier = container.read(gameSessionProvider.notifier);
    notifier.openPracticeMenu();
    handleSystemBack(notifier, container.read(gameSessionProvider));
    expect(container.read(gameSessionProvider).phase, GamePhase.menu);
  });

  test('Back from tutorial returns to menu without history', () {
    final notifier = container.read(gameSessionProvider.notifier);
    notifier.startGame();
    expect(container.read(gameSessionProvider).phase, GamePhase.tutorial);

    handleSystemBack(notifier, container.read(gameSessionProvider));
    expect(container.read(gameSessionProvider).phase, GamePhase.menu);
    expect(container.read(sessionHistoryProvider), isEmpty);
  });

  test('Back from countdown returns to practice menu', () {
    final notifier = container.read(gameSessionProvider.notifier);
    notifier.startPractice(type: MiniGameType.visual);
    expect(container.read(gameSessionProvider).phase, GamePhase.countdown);

    handleSystemBack(notifier, container.read(gameSessionProvider));
    expect(container.read(gameSessionProvider).phase, GamePhase.practiceMenu);
  });

  test('Back from results returns to menu without duplicating history', () {
    fakeAsync((async) {
      final notifier = container.read(gameSessionProvider.notifier);
      notifier.startGame();
      notifier.beginPlaying();
      notifier.addScore(500);
      notifier.endRun();
      async.flushMicrotasks();

      expect(container.read(gameSessionProvider).phase, GamePhase.scoreScreen);
      final historyCount = container.read(sessionHistoryProvider).length;

      handleSystemBack(notifier, container.read(gameSessionProvider));
      expect(container.read(gameSessionProvider).phase, GamePhase.menu);
      expect(container.read(sessionHistoryProvider).length, historyCount);
    });
  });

  test('Back from settings and my progress closes them', () {
    final notifier = container.read(gameSessionProvider.notifier);
    notifier.openSettings();
    handleSystemBack(notifier, container.read(gameSessionProvider));
    expect(container.read(gameSessionProvider).phase, GamePhase.menu);

    notifier.openMyProgress();
    handleSystemBack(notifier, container.read(gameSessionProvider));
    expect(container.read(gameSessionProvider).phase, GamePhase.menu);
  });

  testWidgets('GameplayPauseHost opens pause dialog on pauseMenuRequestId', (
    tester,
  ) async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GameplayPauseHost(
            child: Scaffold(body: Text('Game')),
          ),
        ),
      ),
    );
    await tester.pump();

    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(type: MiniGameType.math);
    session.beginPlaying();
    await tester.pump();

    session.pauseGame();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Paused'), findsOneWidget);
    expect(find.byType(PauseMenuDialog), findsNothing); // abstract helper
    expect(find.text('First pause is free. No time penalty.'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Paused'), findsNothing);
    expect(container.read(gameSessionProvider).isPaused, isFalse);

    session.resetToMenu();
    await tester.pump();
  });
}
