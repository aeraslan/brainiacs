import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../application/player_statistics_provider.dart';
import 'stat_tile.dart';

/// 2-column responsive grid of the four primary statistics.
class PrimaryStatsGrid extends ConsumerWidget {
  const PrimaryStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gamesPlayed = ref.watch(
      playerStatisticsProvider.select((s) => s.gamesPlayed),
    );
    final personalBest = ref.watch(
      playerStatisticsProvider.select((s) => s.personalBest),
    );
    final latestScore = ref.watch(
      playerStatisticsProvider.select((s) => s.latestScore),
    );
    final averageScore = ref.watch(
      playerStatisticsProvider.select((s) => s.averageScore),
    );
    final hasLegacyOnly = ref.watch(
      playerStatisticsProvider.select((s) => s.hasLegacyProgressOnly),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatTile(
                  label: l10n.progressGamesPlayed,
                  icon: Icons.sports_esports_rounded,
                  accent: AppColors.electricBlue,
                  value: gamesPlayed,
                  entranceDelay: Duration.zero,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  label: l10n.progressPersonalBest,
                  icon: Icons.emoji_events_rounded,
                  accent: AppColors.sunnyYellow,
                  value: personalBest,
                  entranceDelay: 60.ms,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatTile(
                  label: l10n.progressLatestScore,
                  icon: Icons.bolt_rounded,
                  accent: AppColors.coral,
                  value: latestScore,
                  entranceDelay: 120.ms,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  label: l10n.progressAverageScore,
                  icon: Icons.insights_rounded,
                  accent: AppColors.mint,
                  value: averageScore,
                  caption: l10n.progressLast10Runs,
                  entranceDelay: 180.ms,
                ),
              ),
            ],
          ),
        ),
        if (hasLegacyOnly) ...[
          const SizedBox(height: AppSpacing.sm),
          const _HistoryPendingNote(),
        ],
      ],
    );
  }
}

class _HistoryPendingNote extends StatelessWidget {
  const _HistoryPendingNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textSecondary.withValues(alpha: 0.9),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            context.l10n.progressLegacyNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}
