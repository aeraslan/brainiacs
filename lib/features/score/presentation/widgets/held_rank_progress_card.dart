import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/rank/title_tier.dart';
import '../../../../core/rank/title_tier_l10n.dart';
import '../../../../core/utils/score_format.dart';
import 'rank_defend_chip.dart';
import 'rank_ladder_sheet.dart';

/// Compact held-rank summary shown after the roulette reveal.
class HeldRankProgressCard extends StatelessWidget {
  const HeldRankProgressCard({
    super.key,
    required this.heldTitle,
    required this.runScore,
    this.daysLeftToDefend,
    this.defendOutcome,
  });

  final TitleTier heldTitle;
  final int runScore;
  final int? daysLeftToDefend;
  final RankDefendOutcome? defendOutcome;

  @override
  Widget build(BuildContext context) {
    final next = heldTitle.nextHigher;
    final progress = heldTitle.progressToNext(runScore);
    final light = Color.lerp(heldTitle.color, Colors.white, 0.35)!;
    final dark = Color.lerp(heldTitle.color, Colors.black, 0.18)!;
    final showDefend = defendOutcome != null && daysLeftToDefend != null;
    final l10n = context.l10n;

    return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(
              color: heldTitle.color.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [light, heldTitle.color, dark],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          heldTitle.icon,
                          color: AppColors.onAccent,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heldTitle.localizedName(l10n),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            l10n.rankOf(heldTitle.rankNumber, TitleTier.count),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showDefend) ...[
                  const SizedBox(height: AppSpacing.sm),
                  RankDefendChip.compactRow(
                    heldTitle: heldTitle,
                    daysLeft: daysLeftToDefend!,
                    outcome: defendOutcome!,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                if (next == null) ...[
                  Text(
                    l10n.rankTopReached,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  Text(
                    l10n.rankNext(next.localizedName(l10n)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.xl),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.surfaceElevated,
                      color: heldTitle.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.rankThisRunProgress(
                      formatScore(
                        runScore,
                        locale: Localizations.localeOf(context).toString(),
                      ),
                      formatScore(
                        next.minScore,
                        locale: Localizations.localeOf(context).toString(),
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        RankLadderSheet.show(context, heldTitle: heldTitle),
                    child: Text(
                      l10n.rankViewAll,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.12, end: 0, duration: 320.ms, curve: Curves.easeOut);
  }
}
