import 'package:brainiacs_flutter/core/rank/title_progress_notifier.dart';
import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/features/statistics/application/player_statistics_provider.dart';
import 'package:brainiacs_flutter/features/statistics/domain/game_session_record.dart';
import 'package:brainiacs_flutter/features/statistics/presentation/my_progress_screen.dart';
import 'package:brainiacs_flutter/features/statistics/presentation/widgets/performance_chart.dart';
import 'package:brainiacs_flutter/main.dart';
import 'package:brainiacs_flutter/shared/widgets/scroll_more_cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _legacyNote =
    'Detailed score tracking starts with your next completed game.';
const _emptyTitle = 'Your progress starts here!';

Map<String, dynamic> _historyEntry({
  required String id,
  required int score,
  required DateTime at,
}) {
  return GameSessionRecord(
    id: id,
    completedAt: at,
    totalScore: score,
    categoryScores: {
      MiniGameType.math: score ~/ 4,
      MiniGameType.memory: score ~/ 4,
      MiniGameType.analytical: score ~/ 4,
      MiniGameType.visual: score - 3 * (score ~/ 4),
    },
  ).toMap();
}

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  Map<String, dynamic>? storage,
  DateTime Function()? clock,
  double textScale = 1,
}) async {
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(
          LocalStorageService.memory(storage),
        ),
        if (clock != null) clockProvider.overrideWithValue(clock),
      ],
      child: Builder(
        builder: (context) {
          container = ProviderScope.containerOf(context);
          return const BrainiacsApp();
        },
      ),
    ),
  );
  await _waitForHydrate(tester, container);
  return container;
}

Future<void> _waitForHydrate(
  WidgetTester tester,
  ProviderContainer container,
) async {
  for (var i = 0; i < 40; i++) {
    if (container.read(titleProgressProvider).isHydrated) {
      await tester.pump();
      return;
    }
    await tester.pump(const Duration(milliseconds: 10));
  }
  fail('titleProgressProvider did not hydrate in time');
}

Future<void> _openProgress(
  WidgetTester tester,
  ProviderContainer container,
) async {
  container.read(gameSessionProvider.notifier).openMyProgress();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _disposeAnimations(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('My Progress opens from menu and back returns to menu', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(tester);

    expect(find.text('My Progress'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsNothing);

    await tester.tap(find.text('My Progress'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MyProgressScreen), findsOneWidget);
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('Personal Best'), findsOneWidget);
    expect(find.text('Latest Score'), findsOneWidget);
    expect(find.text('Average Score'), findsOneWidget);
    expect(find.text('Last 10 runs'), findsOneWidget);
    expect(find.text('Dormant Mind'), findsWidgets);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('New Game'), findsOneWidget);
    expect(find.byType(MyProgressScreen), findsNothing);
    expect(container.read(gameSessionProvider).phase, GamePhase.menu);

    await _disposeAnimations(tester);
  });

  testWidgets('empty history shows polished empty state', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(tester);
    await _openProgress(tester, container);

    expect(find.byType(MyProgressScreen), findsOneWidget);
    expect(find.text(_emptyTitle), findsOneWidget);
    expect(
      find.textContaining('Complete your next New Game session'),
      findsOneWidget,
    );
    expect(find.text(_legacyNote), findsNothing);
    expect(find.text('—'), findsWidgets);

    await _disposeAnimations(tester);
  });

  testWidgets('legacy progress shows pending note and empty state', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 11, 19, 12);
    final container = await _pumpApp(
      tester,
      storage: {
        LocalStorageService.totalGamesPlayedKey: 4,
        LocalStorageService.highestScoreKey: 4500,
        LocalStorageService.currentRankIndexKey: TitleTier.activeNeuron.index,
        LocalStorageService.lastPlayedDateKey:
            DateTime(2026, 11, 17).toIso8601String(),
      },
      clock: () => now,
    );
    await _openProgress(tester, container);

    expect(find.text(_legacyNote), findsOneWidget);
    expect(find.text(_emptyTitle), findsOneWidget);
    expect(find.text('Active Neuron'), findsWidgets);
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('Personal Best'), findsOneWidget);

    final stats = container.read(playerStatisticsProvider);
    expect(stats.gamesPlayed, 4);
    expect(stats.personalBest, 4500);
    expect(stats.latestScore, isNull);
    expect(stats.averageScore, isNull);
    expect(stats.hasLegacyProgressOnly, isTrue);

    await _disposeAnimations(tester);
  });

  testWidgets('history data hides legacy note and shows chart', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(
      tester,
      storage: {
        LocalStorageService.totalGamesPlayedKey: 3,
        LocalStorageService.highestScoreKey: 3000,
        LocalStorageService.sessionHistoryKey: [
          _historyEntry(
            id: '1',
            score: 1000,
            at: DateTime(2026, 11, 1),
          ),
          _historyEntry(
            id: '2',
            score: 2000,
            at: DateTime(2026, 11, 2),
          ),
          _historyEntry(
            id: '3',
            score: 3000,
            at: DateTime(2026, 11, 3),
          ),
        ],
      },
    );
    await _openProgress(tester, container);

    expect(find.text('Recent Performance'), findsOneWidget);
    expect(find.byType(PerformanceChart), findsOneWidget);
    expect(find.text(_emptyTitle), findsNothing);
    expect(find.text(_legacyNote), findsNothing);

    final stats = container.read(playerStatisticsProvider);
    expect(stats.latestScore, 3000);
    expect(stats.averageScore, 2000);
    expect(stats.recentSessions, hasLength(3));
    expect(stats.hasLegacyProgressOnly, isFalse);

    await _disposeAnimations(tester);
  });

  testWidgets('View All Ranks opens the ladder sheet', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(tester);
    await _openProgress(tester, container);

    await tester.tap(find.text('View All Ranks'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('All Ranks'), findsOneWidget);

    await _disposeAnimations(tester);
  });

  testWidgets('compact My Progress screen has no overflow', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(
      tester,
      storage: {
        LocalStorageService.totalGamesPlayedKey: 2,
        LocalStorageService.highestScoreKey: 2200,
        LocalStorageService.sessionHistoryKey: [
          _historyEntry(
            id: 'a',
            score: 1800,
            at: DateTime(2026, 10, 1),
          ),
          _historyEntry(
            id: 'b',
            score: 2200,
            at: DateTime(2026, 10, 2),
          ),
        ],
      },
    );
    await _openProgress(tester, container);

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pump();

    expect(find.byType(MyProgressScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text(ScrollMoreCue.label), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(ScrollMoreCue.label), findsNothing);

    await _disposeAnimations(tester);
  });

  testWidgets('compact screen with larger text scale has no overflow', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(
      tester,
      textScale: 1.3,
      storage: {
        LocalStorageService.totalGamesPlayedKey: 2,
        LocalStorageService.highestScoreKey: 2200,
        LocalStorageService.currentRankIndexKey:
            TitleTier.sharpIntellect.index,
        LocalStorageService.lastPlayedDateKey:
            DateTime(2026, 11, 17).toIso8601String(),
        LocalStorageService.sessionHistoryKey: [
          _historyEntry(
            id: 'a',
            score: 1800,
            at: DateTime(2026, 10, 1),
          ),
          _historyEntry(
            id: 'b',
            score: 2200,
            at: DateTime(2026, 10, 2),
          ),
        ],
      },
      clock: () => DateTime(2026, 11, 19, 12),
    );
    await _openProgress(tester, container);

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pump();

    expect(find.byType(MyProgressScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await _disposeAnimations(tester);
  });

  testWidgets('openMyProgress from notifier shows screen sections', (
    WidgetTester tester,
  ) async {
    final container = await _pumpApp(tester);
    await _openProgress(tester, container);

    expect(find.byType(MyProgressScreen), findsOneWidget);
    expect(find.text('Category Records'), findsOneWidget);
    expect(find.byType(PerformanceChart), findsOneWidget);
    expect(find.text('View All Ranks'), findsOneWidget);
    expect(find.text('Average Score'), findsOneWidget);

    await _disposeAnimations(tester);
  });
}
