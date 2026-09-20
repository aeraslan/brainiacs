import 'package:brainiacs_flutter/core/rank/title_progress_notifier.dart';
import 'package:brainiacs_flutter/core/rank/title_progress_state.dart';
import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime fakeNow;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeNow = DateTime(2026, 9, 20, 12);
  });

  ProviderContainer createContainer({
    Map<String, Object> prefs = const {},
  }) {
    SharedPreferences.setMockInitialValues(prefs);
    return ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => fakeNow),
      ],
    );
  }

  Future<void> waitForHydrate(ProviderContainer container) async {
    // Allow the microtask hydrate + prefs Future to settle.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 10; i++) {
      if (container.read(titleProgressProvider).isHydrated) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('recordLoopScore unlocks a higher title and sets lastEarnedDate',
      () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(4500);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.activeNeuron);
    expect(state.lastSessionTitle, TitleTier.activeNeuron);
    expect(state.unlockedNewRank, isTrue);
    expect(state.lastEarnedDate, fakeNow);
  });

  test('recordLoopScore matching highest refreshes date without unlock',
      () async {
    final container = createContainer(
      prefs: {
        TitleProgressNotifier.highestTitleKey: TitleTier.activeNeuron.name,
        // Within the 7-day defend window relative to fakeNow (Sep 20).
        TitleProgressNotifier.lastEarnedDateKey:
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
    notifier.recordLoopScore(4500);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.activeNeuron);
    expect(state.unlockedNewRank, isFalse);
    expect(state.lastEarnedDate, fakeNow);
  });

  test('recordLoopScore below highest leaves date untouched', () async {
    final previous = DateTime(2026, 9, 18);
    final container = createContainer(
      prefs: {
        TitleProgressNotifier.highestTitleKey: TitleTier.quantumBrain.name,
        TitleProgressNotifier.lastEarnedDateKey: previous.toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final notifier = container.read(titleProgressProvider.notifier);
    notifier.recordLoopScore(2000);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.quantumBrain);
    expect(state.lastSessionTitle, TitleTier.mindApprentice);
    expect(state.unlockedNewRank, isFalse);
    expect(state.lastEarnedDate, previous);
  });

  test('applyDecayIfNeeded drops one tier after 7 days', () async {
    final container = createContainer(
      prefs: {
        TitleProgressNotifier.highestTitleKey: TitleTier.sharpIntellect.name,
        TitleProgressNotifier.lastEarnedDateKey:
            DateTime(2026, 9, 13).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    // Hydrate already runs decay; 7 days from Sep 13 to Sep 20.
    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.activeNeuron);
    expect(state.lastEarnedDate, fakeNow);
  });

  test('applyDecayIfNeeded does not drop before 7 days', () async {
    final earned = DateTime(2026, 9, 14); // 6 days before fakeNow
    final container = createContainer(
      prefs: {
        TitleProgressNotifier.highestTitleKey: TitleTier.sharpIntellect.name,
        TitleProgressNotifier.lastEarnedDateKey: earned.toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.sharpIntellect);
    expect(state.lastEarnedDate, earned);
  });

  test('applyDecayIfNeeded floors at Dormant Mind', () async {
    final container = createContainer(
      prefs: {
        TitleProgressNotifier.highestTitleKey: TitleTier.dormantMind.name,
        TitleProgressNotifier.lastEarnedDateKey:
            DateTime(2026, 9, 1).toIso8601String(),
      },
    );
    addTearDown(container.dispose);
    await waitForHydrate(container);

    final state = container.read(titleProgressProvider);
    expect(state.highestTitle, TitleTier.dormantMind);
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
