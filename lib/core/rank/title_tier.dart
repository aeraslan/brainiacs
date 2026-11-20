import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Eight player titles earned from a full 4-game core-loop total score.
enum TitleTier {
  dormantMind(
    minScore: 0,
    color: Color(0xFF9AA0B8),
    icon: Icons.nights_stay_rounded,
  ),
  mindApprentice(
    minScore: 1500,
    color: AppColors.mint,
    icon: Icons.school_rounded,
  ),
  activeNeuron(
    minScore: 3000,
    color: AppColors.electricBlue,
    icon: Icons.bolt_rounded,
  ),
  sharpIntellect(
    minScore: 4500,
    color: AppColors.coral,
    icon: Icons.lightbulb_rounded,
  ),
  analyticMind(
    minScore: 6000,
    color: Color(0xFFFF9F43),
    icon: Icons.insights_rounded,
  ),
  quantumBrain(
    minScore: 7500,
    color: AppColors.vibrantPurple,
    icon: Icons.blur_circular_rounded,
  ),
  synapseLord(
    minScore: 9000,
    color: AppColors.sunnyYellow,
    icon: Icons.auto_awesome_rounded,
  ),
  brainiac(
    minScore: 10500,
    color: Color(0xFFFF4D8D),
    icon: Icons.emoji_events_rounded,
  );

  const TitleTier({
    required this.minScore,
    required this.color,
    required this.icon,
  });

  final int minScore;
  final Color color;
  final IconData icon;

  /// 1-based position in the ladder (Dormant Mind = 1).
  int get rankNumber => index + 1;

  /// Total number of configured ranks.
  static int get count => values.length;

  bool get isHighest => index == values.length - 1;

  /// Next rank up, or null at the top of the ladder.
  TitleTier? get nextHigher {
    if (isHighest) {
      return null;
    }
    return TitleTier.values[index + 1];
  }

  /// One tier lower for decay. Stays put at [dormantMind].
  TitleTier get nextLower {
    if (this == TitleTier.dormantMind) {
      return this;
    }
    return TitleTier.values[index - 1];
  }

  bool isHigherThan(TitleTier other) => index > other.index;

  bool isAtLeast(TitleTier other) => index >= other.index;

  /// Progress of [runScore] from this tier toward [nextHigher], clamped to 0–1.
  ///
  /// Uses the run score (not personal best) so demotion does not show a filled
  /// bar that implies a guaranteed promotion. At the top rank returns 1.
  double progressToNext(int runScore) {
    final next = nextHigher;
    if (next == null) {
      return 1;
    }
    final span = next.minScore - minScore;
    if (span <= 0) {
      return 1;
    }
    final progressed = runScore - minScore;
    if (progressed <= 0) {
      return 0;
    }
    if (progressed >= span) {
      return 1;
    }
    return progressed / span;
  }

  /// Highest tier whose [minScore] is ≤ [score].
  static TitleTier fromScore(int score) {
    final safe = score < 0 ? 0 : score;
    TitleTier result = TitleTier.dormantMind;
    for (final tier in TitleTier.values) {
      if (safe >= tier.minScore) {
        result = tier;
      }
    }
    return result;
  }

  static TitleTier? tryParse(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    for (final tier in TitleTier.values) {
      if (tier.name == name) {
        return tier;
      }
    }
    return null;
  }
}
