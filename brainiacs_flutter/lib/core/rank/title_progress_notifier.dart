import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'title_progress_state.dart';
import 'title_tier.dart';

/// Injectable clock for decay tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class TitleProgressNotifier extends Notifier<TitleProgressState> {
  static const String highestTitleKey = 'highest_title';
  static const String lastEarnedDateKey = 'last_earned_date';

  @override
  TitleProgressState build() {
    // Fire-and-forget hydrate; UI starts with in-memory defaults.
    Future<void>.microtask(_hydrate);
    return TitleProgressState.initial();
  }

  DateTime get _now => ref.read(clockProvider)();

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) {
      return;
    }

    final storedTitle =
        TitleTier.tryParse(prefs.getString(highestTitleKey)) ??
            TitleTier.dormantMind;
    final storedDateRaw = prefs.getString(lastEarnedDateKey);
    final storedDate =
        storedDateRaw == null ? null : DateTime.tryParse(storedDateRaw);

    state = state.copyWith(
      highestTitle: storedTitle,
      lastEarnedDate: storedDate,
      isHydrated: true,
      unlockedNewRank: false,
      clearLastSessionTitle: true,
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
      clearLastSessionTitle: true,
    );
    _persist(next, resetDate);
  }

  /// Records the title earned from a completed 4-game core loop.
  void recordLoopScore(int totalScore) {
    final sessionTitle = TitleTier.fromScore(totalScore);
    final highest = state.highestTitle;

    if (sessionTitle.isHigherThan(highest)) {
      final earnedAt = _now;
      state = state.copyWith(
        highestTitle: sessionTitle,
        lastEarnedDate: earnedAt,
        lastSessionTitle: sessionTitle,
        unlockedNewRank: true,
      );
      _persist(sessionTitle, earnedAt);
      return;
    }

    if (sessionTitle == highest) {
      final earnedAt = _now;
      state = state.copyWith(
        lastEarnedDate: earnedAt,
        lastSessionTitle: sessionTitle,
        unlockedNewRank: false,
      );
      _persist(highest, earnedAt);
      return;
    }

    // Lower than stored highest — keep date and rank untouched.
    state = state.copyWith(
      lastSessionTitle: sessionTitle,
      unlockedNewRank: false,
    );
  }

  Future<void> _persist(TitleTier title, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(highestTitleKey, title.name);
    await prefs.setString(lastEarnedDateKey, date.toIso8601String());
  }
}

final titleProgressProvider =
    NotifierProvider<TitleProgressNotifier, TitleProgressState>(
  TitleProgressNotifier.new,
);
