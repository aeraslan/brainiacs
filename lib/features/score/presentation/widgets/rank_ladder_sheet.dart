import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/rank/title_progress_state.dart';
import '../../../../core/rank/title_tier.dart';

/// Bottom sheet listing every configured rank with the held rank highlighted.
abstract final class RankLadderSheet {
  static Future<void> show(
    BuildContext context, {
    required TitleTier heldTitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RankLadderSheetBody(heldTitle: heldTitle);
      },
    );
  }
}

class _RankLadderSheetBody extends StatelessWidget {
  const _RankLadderSheetBody({required this.heldTitle});

  final TitleTier heldTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiers = TitleTier.values.reversed.toList(growable: false);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.xl),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppSpacing.xl),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.rankAllRanks,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.rankLadderExplainer(TitleProgressState.decayDays),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: tiers.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final tier = tiers[index];
                        return _RankLadderRow(
                          tier: tier,
                          isCurrent: tier == heldTitle,
                          isBelow: tier.index < heldTitle.index,
                          isAbove: tier.index > heldTitle.index,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankLadderRow extends StatelessWidget {
  const _RankLadderRow({
    required this.tier,
    required this.isCurrent,
    required this.isBelow,
    required this.isAbove,
  });

  final TitleTier tier;
  final bool isCurrent;
  final bool isBelow;
  final bool isAbove;

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(tier.color, Colors.white, 0.35)!;
    final dark = Color.lerp(tier.color, Colors.black, 0.18)!;
    final opacity = isBelow ? 0.55 : 1.0;

    final decoration = isCurrent
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [light, tier.color, dark],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: tier.color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: tier.color.withValues(alpha: isAbove ? 0.35 : 0.2),
              width: 1.25,
            ),
          );

    final titleColor = isCurrent ? AppColors.onAccent : AppColors.textPrimary;
    final metaColor =
        isCurrent ? AppColors.onAccent.withValues(alpha: 0.9) : AppColors.textSecondary;

    return Opacity(
      opacity: isBelow ? 0.85 : 1,
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                tier.icon,
                color: isCurrent ? AppColors.onAccent : tier.color,
                size: 26,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.label,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      context.l10n.rankLadderEntry(tier.rankNumber, tier.minScore),
                      style: TextStyle(
                        color: metaColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppSpacing.xl),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      context.l10n.rankYou,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                )
              else if (isBelow)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.correct.withValues(alpha: 0.85),
                  size: 22,
                )
              else
                Icon(
                  Icons.lock_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
