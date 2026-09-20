import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/rank/title_progress_state.dart';

/// Candy chip showing how many days remain before rank decay.
class RankDefendChip extends StatelessWidget {
  const RankDefendChip({
    super.key,
    required this.daysLeft,
  });

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final label = daysLeft <= 0
        ? 'Defend your rank today!'
        : daysLeft == 1
            ? '1 day left to defend your rank!'
            : '$daysLeft days left to defend your rank!';

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_moon_rounded,
              color: urgent ? AppColors.coral : AppColors.electricBlue,
              size: 20,
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
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
  }) {
    final days = progress.daysLeftToDefend(now);
    if (days == null) {
      return null;
    }
    return RankDefendChip(daysLeft: days);
  }
}
