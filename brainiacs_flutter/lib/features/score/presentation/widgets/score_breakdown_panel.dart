import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/session/game_session_state.dart';

/// Floating chunky candy skill bars for each mini-game.
class ScoreBreakdownPanel extends StatelessWidget {
  const ScoreBreakdownPanel({
    super.key,
    required this.scoresByGame,
  });

  final Map<MiniGameType, int> scoresByGame;

  static const int maxSkillScore = 1000;
  static const double barHeight = 60;
  static const Color _trackGrey = Color(0xFFE8EAF0);
  static const double _barGap = AppSpacing.sm + AppSpacing.xs;

  static const List<_CandyBarData> _rows = [
    _CandyBarData(
      type: MiniGameType.math,
      label: 'Math',
      icon: Icons.calculate_rounded,
      // Matches GameBackgroundStyle.mathYellow accent.
      color: Color(0xFFFFE566),
    ),
    _CandyBarData(
      type: MiniGameType.memory,
      label: 'Memory',
      icon: Icons.psychology_rounded,
      // Matches GameBackgroundStyle.memoryGreen accent.
      color: Color(0xFFA8E6A3),
    ),
    _CandyBarData(
      type: MiniGameType.analytical,
      label: 'Analytic',
      icon: Icons.extension_rounded,
      // Matches GameBackgroundStyle.cubeOrange accent.
      color: Color(0xFFFFBE7D),
    ),
    _CandyBarData(
      type: MiniGameType.visual,
      label: 'Visual',
      icon: Icons.visibility_rounded,
      // Matches VisualColors.sky.
      color: Color(0xFF7EC8E3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _rows.length; i++) ...[
          if (i > 0) const SizedBox(height: _barGap),
          _ChunkyCandyBar(
            data: _rows[i],
            score: scoresByGame[_rows[i].type] ?? 0,
            index: i,
          ),
        ],
      ],
    );
  }
}

class _CandyBarData {
  const _CandyBarData({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });

  final MiniGameType type;
  final String label;
  final IconData icon;
  final Color color;
}

class _ChunkyCandyBar extends StatelessWidget {
  const _ChunkyCandyBar({
    required this.data,
    required this.score,
    required this.index,
  });

  final _CandyBarData data;
  final int score;
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
                    data.color.withValues(alpha: 0.15),
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
                          ColoredBox(color: data.color),
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
                        data.icon,
                        color: AppColors.textPrimary,
                        size: 24,
                        shadows: _contentShadow,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          data.label,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            shadows: _contentShadow,
                          ),
                        ),
                      ),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
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
