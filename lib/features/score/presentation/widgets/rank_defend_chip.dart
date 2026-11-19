import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/rank/title_progress_state.dart';
import '../../../../core/rank/title_tier.dart';

/// How this run relates to the player's held rank for defend messaging.
enum RankDefendOutcome {
  /// This run raised the held rank.
  unlocked,

  /// This run matched the held rank (timer reset).
  defended,

  /// This run was below the held rank (timer unchanged).
  pending,
}

/// Candy chip showing which held rank needs defending and how many days remain.
class RankDefendChip extends StatelessWidget {
  const RankDefendChip({
    super.key,
    required this.heldTitle,
    required this.daysLeft,
    required this.outcome,
  });

  final TitleTier heldTitle;
  final int daysLeft;
  final RankDefendOutcome outcome;

  /// Compact inline row for embedding inside [HeldRankProgressCard].
  ///
  /// Same copy and shield icon as the standalone chip, without the outer pill.
  static Widget compactRow({
    required TitleTier heldTitle,
    required int daysLeft,
    required RankDefendOutcome outcome,
  }) {
    return _RankDefendContent(
      heldTitle: heldTitle,
      daysLeft: daysLeft,
      outcome: outcome,
      compact: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urgent = daysLeft <= 2;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(
          color: (urgent ? AppColors.coral : AppColors.electricBlue)
              .withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: _RankDefendContent(
          heldTitle: heldTitle,
          daysLeft: daysLeft,
          outcome: outcome,
          compact: false,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 300.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          delay: 200.ms,
          duration: 360.ms,
          curve: Curves.easeOut,
        );
  }

  /// Builds from progress state, or returns null when there is nothing to show.
  static Widget? maybeOf({
    required TitleProgressState progress,
    required DateTime now,
    required TitleTier sessionTitle,
  }) {
    final days = progress.daysLeftToDefend(now);
    if (days == null) {
      return null;
    }
    if (progress.highestTitle == TitleTier.dormantMind &&
        !progress.unlockedNewRank) {
      return null;
    }

    final RankDefendOutcome outcome;
    if (progress.unlockedNewRank) {
      outcome = RankDefendOutcome.unlocked;
    } else if (sessionTitle == progress.highestTitle) {
      outcome = RankDefendOutcome.defended;
    } else {
      outcome = RankDefendOutcome.pending;
    }

    return RankDefendChip(
      heldTitle: progress.highestTitle,
      daysLeft: days,
      outcome: outcome,
    );
  }
}

class _RankDefendContent extends StatelessWidget {
  const _RankDefendContent({
    required this.heldTitle,
    required this.daysLeft,
    required this.outcome,
    required this.compact,
  });

  final TitleTier heldTitle;
  final int daysLeft;
  final RankDefendOutcome outcome;
  final bool compact;

  String _defendStatus(AppLocalizations l10n) {
    if (daysLeft <= 0) {
      return l10n.rankDefendToday;
    }
    return l10n.rankDaysLeft(daysLeft);
  }

  String _label(AppLocalizations l10n) {
    final name = heldTitle.label;
    final status = _defendStatus(l10n);
    return switch (outcome) {
      RankDefendOutcome.unlocked => daysLeft <= 0
          ? l10n.rankDefendChipNew(name)
          : l10n.rankDefendChipDefend(name, status),
      RankDefendOutcome.defended =>
        l10n.rankDefendChipDefended(name, status),
      RankDefendOutcome.pending => l10n.rankDefendChipHeld(name, status),
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = _label(context.l10n);
    final urgent = daysLeft <= 2;
    final accent = urgent ? AppColors.coral : AppColors.electricBlue;
    final iconSize = compact ? 18.0 : 20.0;
    final fontSize = compact ? 13.0 : 14.0;

    return Row(
      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(
          Icons.shield_moon_rounded,
          color: accent,
          size: iconSize,
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 700.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
