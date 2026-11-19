import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/session/game_session_state.dart';
import '../../../../shared/constants/mini_game_category_style.dart';

/// Floating chunky candy skill bars for each mini-game.
class ScoreBreakdownPanel extends StatelessWidget {
  const ScoreBreakdownPanel({
    super.key,
    required this.scoresByGame,
    this.newCategoryHighs = const <MiniGameType>{},
  });

  final Map<MiniGameType, int> scoresByGame;
  final Set<MiniGameType> newCategoryHighs;

  /// Excellent-play ceiling (~25 corrects at 100 pts in a 60s stage).
  static const int maxSkillScore = 2500;
  static const double barHeight = 42;
  static const Color _trackGrey = Color(0xFFE8EAF0);
  static const double _barGap = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < MiniGameType.values.length; i++) ...[
          if (i > 0) const SizedBox(height: _barGap),
          _ChunkyCandyBar(
            type: MiniGameType.values[i],
            score: scoresByGame[MiniGameType.values[i]] ?? 0,
            isNewHigh: newCategoryHighs.contains(MiniGameType.values[i]),
            index: i,
          ),
        ],
      ],
    );
  }
}

class _ChunkyCandyBar extends StatelessWidget {
  const _ChunkyCandyBar({
    required this.type,
    required this.score,
    required this.isNewHigh,
    required this.index,
  });

  final MiniGameType type;
  final int score;
  final bool isNewHigh;
  final int index;

  static const List<Shadow> _contentShadow = [
    Shadow(
      color: Color(0x33FFFFFF),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final entryDelayMs = index * 120;
    final fillDelayMs = entryDelayMs + 280;
    final fraction =
        (score / ScoreBreakdownPanel.maxSkillScore).clamp(0.0, 1.0);
    final radius = BorderRadius.circular(ScoreBreakdownPanel.barHeight / 2);
    final color = type.color;

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: ScoreBreakdownPanel.barHeight,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Color.alphaBlend(
                    color.withValues(alpha: 0.15),
                    ScoreBreakdownPanel._trackGrey,
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: fraction,
                      heightFactor: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: color),
                          Align(
                            alignment: Alignment.topCenter,
                            child: FractionallySizedBox(
                              heightFactor: 0.35,
                              widthFactor: 1,
                              child: ColoredBox(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scaleX(
                            begin: 0,
                            end: 1,
                            alignment: Alignment.centerLeft,
                            delay: fillDelayMs.ms,
                            duration: 650.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        type.icon,
                        color: AppColors.textPrimary,
                        size: 20,
                        shadows: _contentShadow,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          type.localizedLabel(context.l10n),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            shadows: _contentShadow,
                          ),
                        ),
                      ),
                      if (isNewHigh) ...[
                        const _NewHighChip(),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          shadows: _contentShadow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: entryDelayMs.ms,
          duration: 320.ms,
        )
        .slideY(
          begin: 0.25,
          end: 0,
          delay: entryDelayMs.ms,
          duration: 380.ms,
          curve: Curves.easeOut,
        );
  }
}

class _NewHighChip extends StatelessWidget {
  const _NewHighChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.coral, AppColors.sunnyYellow],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF6B6B),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          context.l10n.scoreNewHighScore,
          style: const TextStyle(
            color: AppColors.onAccent,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.2,
          ),
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          duration: 700.ms,
          curve: Curves.easeInOut,
        );
  }
}
