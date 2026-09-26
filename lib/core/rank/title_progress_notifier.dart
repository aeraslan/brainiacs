import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/game_session_state.dart';
import '../storage/local_storage_provider.dart';
import 'title_progress_state.dart';
import 'title_tier.dart';

/// Injectable clock for decay tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class TitleProgressNotifier extends Notifier<TitleProgressState> {
  @override
  TitleProgressState build() {
    // Fire-and-forget hydrate; UI starts with in-memory defaults.
    Future<void>.microtask(_hydrate);
    return TitleProgressState.initial();
  }

  DateTime get _now => ref.read(clockProvider)();

  LocalStorageService get _storage => ref.read(localStorageProvider);

  Future<void> _hydrate() async {
    final storage = _storage;
    await storage.migrateFromSharedPreferencesIfNeeded();
    if (!ref.mounted) {
      return;
    }

    final rankIndex = storage.currentRankIndex;
    final highestTitle = TitleTier.values[rankIndex];

    state = state.copyWith(
      highestTitle: highestTitle,
      lastEarnedDate: storage.lastPlayedDate,
      highestScore: storage.highestScore,
      highestScoresByGame: storage.highestScoresByGame,
      totalGamesPlayed: storage.totalGamesPlayed,
      isHydrated: true,
      unlockedNewRank: false,
      hasDecayed: false,
      clearLastSessionTitle: true,
      clearNewCategoryHighs: true,
    );

    applyDecayIfNeeded();
  }

  /// Drops [highestTitle] by one tier when the defend window has expired.
  void applyDecayIfNeeded() {
    final last = state.lastEarnedDate;
    if (last == null) {
      return;
    }
    if (state.highestTitle == TitleTier.dormantMind) {
      return;
    }

    final elapsed = _now.difference(last).inDays;
    if (elapsed < TitleProgressState.decayDays) {
      return;
    }

    final next = state.highestTitle.nextLower;
    final resetDate = _now;
    state = state.copyWith(
      highestTitle: next,
      lastEarnedDate: resetDate,
      unlockedNewRank: false,
      hasDecayed: true,
      clearLastSessionTitle: true,
    );
    _persist();
  }

  /// Records the title earned from a completed 4-game core loop.
  ///
  /// The defend timer only resets when this run matches or beats the held rank.
  /// Category highs update whenever a per-area score beats its stored best.
  void recordLoopScore({
    required int totalScore,
    required Map<MiniGameType, int> scoresByGame,
  }) {
    final sessionTitle = TitleTier.fromScore(totalScore);
    final highest = state.highestTitle;
    final playedAt = _now;
    final nextGamesPlayed = state.totalGamesPlayed + 1;
    final nextHighestScore =
        totalScore > state.highestScore ? totalScore : state.highestScore;

    final nextCategoryHighs =
        Map<MiniGameType, int>.from(state.highestScoresByGame);
    final beaten = <MiniGameType>{};
    for (final type in MiniGameType.values) {
      final runScore = scoresByGame[type] ?? 0;
      final held = nextCategoryHighs[type] ?? 0;
      if (runScore > held) {
        nextCategoryHighs[type] = runScore;
        beaten.add(type);
      }
    }

    if (sessionTitle.isHigherThan(highest)) {
      state = state.copyWith(
        highestTitle: sessionTitle,
        lastEarnedDate: playedAt,
        lastSessionTitle: sessionTitle,
        unlockedNewRank: true,
        highestScore: nextHighestScore,
        highestScoresByGame: nextCategoryHighs,
        newCategoryHighs: beaten,
        totalGamesPlayed: nextGamesPlayed,
        hasDecayed: false,
      );
      _persist();
      return;
    }

    if (sessionTitle == highest) {
      state = state.copyWith(
        lastEarnedDate: playedAt,
        lastSessionTitle: sessionTitle,
        unlockedNewRank: false,
        highestScore: nextHighestScore,
        highestScoresByGame: nextCategoryHighs,
        newCategoryHighs: beaten,
        totalGamesPlayed: nextGamesPlayed,
        hasDecayed: false,
      );
      _persist();
      return;
    }

    // Below held rank — progress counters update, defend window untouched.
    state = state.copyWith(
      lastSessionTitle: sessionTitle,
      unlockedNewRank: false,
      highestScore: nextHighestScore,
      highestScoresByGame: nextCategoryHighs,
      newCategoryHighs: beaten,
      totalGamesPlayed: nextGamesPlayed,
      hasDecayed: false,
    );
    _persist();
  }

  /// Clears the one-shot decay dialog flag after the UI has shown it.
  void acknowledgeDecay() {
    if (!state.hasDecayed) {
      return;
    }
    state = state.copyWith(hasDecayed: false);
  }

  Future<void> _persist() {
    return _storage.persistProgress(
      highestScore: state.highestScore,
      highestScoresByGame: state.highestScoresByGame,
      currentRankIndex: state.currentRankIndex,
      totalGamesPlayed: state.totalGamesPlayed,
      lastPlayedDate: state.lastEarnedDate,
    );
  }
}

final titleProgressProvider =
    NotifierProvider<TitleProgressNotifier, TitleProgressState>(
  TitleProgressNotifier.new,
);
