import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Eight player titles earned from a full 4-game core-loop total score.
enum TitleTier {
  dormantMind(
    label: 'Dormant Mind',
    minScore: 0,
    color: Color(0xFF9AA0B8),
    icon: Icons.nights_stay_rounded,
  ),
  mindApprentice(
    label: 'Mind Apprentice',
    minScore: 2000,
    color: AppColors.mint,
    icon: Icons.school_rounded,
  ),
  activeNeuron(
    label: 'Active Neuron',
    minScore: 4500,
    color: AppColors.electricBlue,
    icon: Icons.bolt_rounded,
  ),
  sharpIntellect(
    label: 'Sharp Intellect',
    minScore: 6500,
    color: AppColors.coral,
    icon: Icons.lightbulb_rounded,
  ),
  analyticMind(
    label: 'Analytic Mind',
    minScore: 8500,
    color: Color(0xFFFF9F43),
    icon: Icons.insights_rounded,
  ),
  quantumBrain(
    label: 'Quantum Brain',
    minScore: 10500,
    color: AppColors.vibrantPurple,
    icon: Icons.blur_circular_rounded,
  ),
  synapseLord(
    label: 'Synapse Lord',
    minScore: 12500,
    color: AppColors.sunnyYellow,
    icon: Icons.auto_awesome_rounded,
  ),
  brainiac(
    label: 'Brainiac',
    minScore: 15000,
    color: Color(0xFFFF4D8D),
    icon: Icons.emoji_events_rounded,
  );

  const TitleTier({
    required this.label,
    required this.minScore,
    required this.color,
    required this.icon,
  });

  final String label;
  final int minScore;
  final Color color;
  final IconData icon;

  /// One tier lower for decay. Stays put at [dormantMind].
  TitleTier get nextLower {
    if (this == TitleTier.dormantMind) {
      return this;
    }
    return TitleTier.values[index - 1];
  }

  bool isHigherThan(TitleTier other) => index > other.index;

  bool isAtLeast(TitleTier other) => index >= other.index;

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
