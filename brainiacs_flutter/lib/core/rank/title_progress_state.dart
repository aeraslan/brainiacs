import 'title_tier.dart';

class TitleProgressState {
  const TitleProgressState({
    required this.highestTitle,
    this.lastEarnedDate,
    this.lastSessionTitle,
    this.unlockedNewRank = false,
    this.isHydrated = false,
  });

  factory TitleProgressState.initial() {
    return const TitleProgressState(
      highestTitle: TitleTier.dormantMind,
    );
  }

  static const int decayDays = 7;

  final TitleTier highestTitle;
  final DateTime? lastEarnedDate;

  /// Title earned for the most recent completed core loop (ephemeral).
  final TitleTier? lastSessionTitle;

  /// True when the latest loop raised [highestTitle] (ephemeral).
  final bool unlockedNewRank;

  /// True after prefs have been loaded (or mocked) at least once.
  final bool isHydrated;

  /// Days remaining before the next decay, or null if no date is stored.
  int? daysLeftToDefend(DateTime now) {
    final last = lastEarnedDate;
    if (last == null) {
      return null;
    }
    final elapsed = now.difference(last).inDays;
    final remaining = decayDays - elapsed;
    if (remaining < 0) {
      return 0;
    }
    if (remaining > decayDays) {
      return decayDays;
    }
    return remaining;
  }

  TitleProgressState copyWith({
    TitleTier? highestTitle,
    DateTime? lastEarnedDate,
    TitleTier? lastSessionTitle,
    bool? unlockedNewRank,
    bool? isHydrated,
    bool clearLastEarnedDate = false,
    bool clearLastSessionTitle = false,
  }) {
    return TitleProgressState(
      highestTitle: highestTitle ?? this.highestTitle,
      lastEarnedDate: clearLastEarnedDate
          ? null
          : (lastEarnedDate ?? this.lastEarnedDate),
      lastSessionTitle: clearLastSessionTitle
          ? null
          : (lastSessionTitle ?? this.lastSessionTitle),
      unlockedNewRank: unlockedNewRank ?? this.unlockedNewRank,
      isHydrated: isHydrated ?? this.isHydrated,
    );
  }
}
