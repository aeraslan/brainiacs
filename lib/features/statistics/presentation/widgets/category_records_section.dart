import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/session/game_session_state.dart';
import '../../../../core/utils/score_format.dart';
import '../../../../shared/constants/mini_game_category_style.dart';
import '../../application/player_statistics_provider.dart';

/// Personal-best scores for each mini-game category (no fill bars).
class CategoryRecordsSection extends ConsumerWidget {
  const CategoryRecordsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryBests = ref.watch(
      playerStatisticsProvider.select((s) => s.categoryBests),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.progressCategoryRecords,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < MiniGameType.values.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _CategoryRecordRow(
            type: MiniGameType.values[i],
            score: categoryBests[MiniGameType.values[i]] ?? 0,
            index: i,
            reduceMotion: reduceMotion,
          ),
        ],
      ],
    );
  }
}

class _CategoryRecordRow extends StatelessWidget {
  const _CategoryRecordRow({
    required this.type,
    required this.score,
    required this.index,
    required this.reduceMotion,
  });

  final MiniGameType type;
  final int score;
  final int index;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final soft = Color.lerp(type.color, Colors.white, 0.7)!;

    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: type.color.withValues(alpha: 0.45),
          width: 1.25,
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
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(type.icon, color: AppColors.textPrimary, size: 22),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                type.localizedLabel(context.l10n),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              formatScore(
                score,
                locale: Localizations.localeOf(context).toString(),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );

    if (reduceMotion) {
      return row;
    }

    final delay = (index * 70).ms;
    return row
        .animate()
        .fadeIn(delay: delay, duration: 280.ms)
        .slideX(
          begin: 0.06,
          end: 0,
          delay: delay,
          duration: 320.ms,
          curve: Curves.easeOut,
        );
  }
}
