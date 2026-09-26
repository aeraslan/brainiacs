import 'package:brainiacs_flutter/core/rank/title_progress_notifier.dart';
import 'package:brainiacs_flutter/core/rank/title_progress_state.dart';
import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime fakeNow;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeNow = DateTime(2026, 9, 20, 12);
  });

  Map<MiniGameType, int> evenScores(int total) {
    final each = total ~/ 4;
    final remainder = total - (each * 4);
    return {
      MiniGameType.math: each + remainder,
      MiniGameType.memory: each,
      MiniGameType.analytical: each,
      MiniGameType.visual: each,
    };
  }

  ProviderContainer createContainer({
    Map<String, dynamic> storage = const {},
    Map<String, Object> prefs = const {},
  }) {
    SharedPreferences.setMockInitialValues(prefs);
    return ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => fakeNow),
        localStorageProvider.overrideWithValue(
          LocalStorageService.memory(Map<String, dynamic>.from(storage)),
        ),
      ],
    );
  }

  Future<void> waitForHydrate(ProviderContainer container) async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 20; i++) {
      if (container.read(titleProgressProvider).isHydrated) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('recordLoopScore unlocks a higher title and sets lastPlayedDate',
      () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(
      totalScore: 4500,
      scoresByGame: evenScores(4500),
    );

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.activeNeuron);
    expect(state.lastSessionTitle, TitleTier.activeNeuron);
    expect(state.unlockedNewRank, isTrue);
    expect(state.lastEarnedDate, fakeNow);
    expect(state.highestScore, 4500);
    expect(state.totalGamesPlayed, 1);
    expect(state.newCategoryHighs, MiniGameType.values.toSet());
    expect(state.highestScoreFor(MiniGameType.math), greaterThan(0));

    final storage = container.read(localStorageProvider);
    expect(storage.currentRankIndex, TitleTier.activeNeuron.index);
    expect(storage.highestScore, 4500);
    expect(storage.totalGamesPlayed, 1);
    expect(storage.lastPlayedDate, fakeNow);
    expect(storage.highestScoreFor(MiniGameType.math), greaterThan(0));
  });

  test('recordLoopScore matching highest refreshes date without unlock',
      () async {
    final container = createContainer(
      storage: {
        LocalStorageService.currentRankIndexKey: TitleTier.activeNeuron.index,
        LocalStorageService.lastPlayedDateKey:
            DateTime(2026, 9, 18).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    expect(
      container.read(titleProgressProvider).highestTitle,
      TitleTier.activeNeuron,
    );

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(
      totalScore: 4500,
      scoresByGame: evenScores(4500),
    );

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.activeNeuron);
    expect(state.unlockedNewRank, isFalse);
    expect(state.lastEarnedDate, fakeNow);
    expect(state.totalGamesPlayed, 1);
  });

  test('recordLoopScore below highest leaves defend date untouched', () async {
    final previous = DateTime(2026, 9, 18);
    final container = createContainer(
      storage: {
        LocalStorageService.currentRankIndexKey: TitleTier.quantumBrain.index,
        LocalStorageService.lastPlayedDateKey: previous.toIso8601String(),
        LocalStorageService.highestScoreKey: 10500,
        LocalStorageService.totalGamesPlayedKey: 3,
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(
      totalScore: 2000,
      scoresByGame: evenScores(2000),
    );

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.quantumBrain);
    expect(state.lastSessionTitle, TitleTier.mindApprentice);
    expect(state.unlockedNewRank, isFalse);
    expect(state.lastEarnedDate, previous);
    expect(state.highestScore, 10500);
    expect(state.totalGamesPlayed, 4);

    final storage = container.read(localStorageProvider);
    expect(storage.lastPlayedDate, previous);
    expect(storage.currentRankIndex, TitleTier.quantumBrain.index);
  });

  test('recordLoopScore sets category highs and marks NEW only for beats',
      () async {
    final container = createContainer(
      storage: {
        LocalStorageService.highestScoreMathKey: 800,
        LocalStorageService.highestScoreMemoryKey: 600,
        LocalStorageService.highestScoreAnalyticalKey: 700,
        LocalStorageService.highestScoreVisualKey: 500,
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(
      totalScore: 2700,
      scoresByGame: {
        MiniGameType.math: 900,
        MiniGameType.memory: 400,
        MiniGameType.analytical: 700,
        MiniGameType.visual: 700,
      },
    );

    final state = container.read(titleProgressProvider);
    expect(state.highestScoreFor(MiniGameType.math), 900);
    expect(state.highestScoreFor(MiniGameType.memory), 600);
    expect(state.highestScoreFor(MiniGameType.analytical), 700);
    expect(state.highestScoreFor(MiniGameType.visual), 700);
    expect(
      state.newCategoryHighs,
      {MiniGameType.math, MiniGameType.visual},
    );

    final storage = container.read(localStorageProvider);
    expect(storage.highestScoreFor(MiniGameType.math), 900);
    expect(storage.highestScoreFor(MiniGameType.memory), 600);
    expect(storage.highestScoreFor(MiniGameType.visual), 700);
  });

  test('recordLoopScore second weaker run does not lower category highs',
      () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(
      totalScore: 4000,
      scoresByGame: {
        MiniGameType.math: 1000,
        MiniGameType.memory: 1000,
        MiniGameType.analytical: 1000,
        MiniGameType.visual: 1000,
      },
    );
    notifier.recordLoopScore(
      totalScore: 1200,
      scoresByGame: {
        MiniGameType.math: 300,
        MiniGameType.memory: 300,
        MiniGameType.analytical: 300,
        MiniGameType.visual: 300,
      },
    );

    final state = container.read(titleProgressProvider);
    expect(state.highestScoreFor(MiniGameType.math), 1000);
    expect(state.newCategoryHighs, isEmpty);
    expect(state.totalGamesPlayed, 2);
  });

  test('applyDecayIfNeeded drops one tier after 7 days and sets hasDecayed',
      () async {
    final container = createContainer(
      storage: {
        LocalStorageService.currentRankIndexKey:
            TitleTier.sharpIntellect.index,
        LocalStorageService.lastPlayedDateKey:
            DateTime(2026, 9, 13).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.activeNeuron);
    expect(state.lastEarnedDate, fakeNow);
    expect(state.hasDecayed, isTrue);

    final storage = container.read(localStorageProvider);
    expect(storage.currentRankIndex, TitleTier.activeNeuron.index);
    expect(storage.lastPlayedDate, fakeNow);
  });

  test('applyDecayIfNeeded does not drop before 7 days', () async {
    final earned = DateTime(2026, 9, 14);
    final container = createContainer(
      storage: {
        LocalStorageService.currentRankIndexKey:
            TitleTier.sharpIntellect.index,
        LocalStorageService.lastPlayedDateKey: earned.toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.sharpIntellect);
    expect(state.lastEarnedDate, earned);
    expect(state.hasDecayed, isFalse);
  });

  test('applyDecayIfNeeded floors at Dormant Mind', () async {
    final container = createContainer(
      storage: {
        LocalStorageService.currentRankIndexKey: TitleTier.dormantMind.index,
        LocalStorageService.lastPlayedDateKey:
            DateTime(2026, 9, 1).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.dormantMind);
    expect(state.hasDecayed, isFalse);
  });

  test('acknowledgeDecay clears hasDecayed flag', () async {
    final container = createContainer(
      storage: {
        LocalStorageService.currentRankIndexKey:
            TitleTier.sharpIntellect.index,
        LocalStorageService.lastPlayedDateKey:
            DateTime(2026, 9, 13).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    expect(container.read(titleProgressProvider).hasDecayed, isTrue);
    container.read(titleProgressProvider.notifier).acknowledgeDecay();
    expect(container.read(titleProgressProvider).hasDecayed, isFalse);
  });

  test('migrates legacy SharedPreferences into storage once', () async {
    final container = createContainer(
      prefs: {
        LocalStorageService.legacyHighestTitleKey: TitleTier.quantumBrain.name,
        LocalStorageService.legacyLastEarnedDateKey:
            DateTime(2026, 9, 18).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.quantumBrain);
    expect(state.lastEarnedDate, DateTime(2026, 9, 18));

    final storage = container.read(localStorageProvider);
    expect(storage.prefsMigrated, isTrue);
    expect(storage.currentRankIndex, TitleTier.quantumBrain.index);
  });

  test('daysLeftToDefend clamps remaining days', () {
    final state = TitleProgressState(
      highestTitle: TitleTier.activeNeuron,
      lastEarnedDate: DateTime(2026, 9, 17),
    );
    expect(state.daysLeftToDefend(DateTime(2026, 9, 20)), 4);
    expect(
      TitleProgressState(
        highestTitle: TitleTier.activeNeuron,
        lastEarnedDate: DateTime(2026, 9, 1),
      ).daysLeftToDefend(DateTime(2026, 9, 20)),
      0,
    );
    expect(
      const TitleProgressState(
        highestTitle: TitleTier.dormantMind,
      ).daysLeftToDefend(DateTime(2026, 9, 20)),
      isNull,
    );
  });
}
