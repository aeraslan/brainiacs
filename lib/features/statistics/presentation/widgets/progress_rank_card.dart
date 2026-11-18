import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/rank/title_progress_notifier.dart';
import '../../../../core/rank/title_tier.dart';
import '../../../score/presentation/widgets/rank_ladder_sheet.dart';

/// Compact dashboard rank summary without a misleading run-progress bar.
class ProgressRankCard extends ConsumerWidget {
  const ProgressRankCard({super.key});

  static const double _cardPadding = AppSpacing.sm + AppSpacing.xs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldTitle = ref.watch(
      titleProgressProvider.select((s) => s.highestTitle),
    );
    final lastEarnedDate = ref.watch(
      titleProgressProvider.select((s) => s.lastEarnedDate),
    );
    final daysLeft = lastEarnedDate == null
        ? null
        : ref.watch(titleProgressProvider).daysLeftToDefend(
              ref.read(clockProvider)(),
            );

    final next = heldTitle.nextHigher;
    final light = Color.lerp(heldTitle.color, Colors.white, 0.35)!;
    final dark = Color.lerp(heldTitle.color, Colors.black, 0.18)!;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final defendDays = daysLeft;

    final card = DecoratedBox(
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
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding: const EdgeInsets.all(AppSpacing.sm - 1),
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
                        heldTitle.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Rank ${heldTitle.rankNumber} of ${TitleTier.count}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (defendDays != null &&
                          heldTitle != TitleTier.dormantMind) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _DefendBadge(daysLeft: defendDays),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (next == null)
              Text(
                'Top rank reached',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              )
            else ...[
              Text(
                'Next: ${next.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Score ${next.minScore}+ in one game',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => RankLadderSheet.show(
                  context,
                  heldTitle: heldTitle,
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Ranks',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.electricBlue,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.electricBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (reduceMotion) {
      return card;
    }

    return card
        .animate()
        .fadeIn(duration: 280.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOut,
        );
  }
}

class _DefendBadge extends StatelessWidget {
  const _DefendBadge({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final urgent = daysLeft <= 2;
    final accent = urgent ? AppColors.coral : AppColors.electricBlue;
    final label = daysLeft <= 0
        ? 'Defend today'
        : daysLeft == 1
            ? '1 day left'
            : '$daysLeft days left';

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.xl),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_moon_rounded, color: accent, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
