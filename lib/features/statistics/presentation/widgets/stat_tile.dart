import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/score_format.dart';

/// Soft candy card showing one primary statistic.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.value,
    this.caption,
    this.animateValue = true,
    this.entranceDelay = Duration.zero,
  });

  final String label;
  final IconData icon;
  final Color accent;

  /// Null displays an em dash.
  final int? value;

  /// Optional right-aligned caption on the icon row (adds no card height).
  final String? caption;
  final bool animateValue;
  final Duration entranceDelay;

  static const Duration countDuration = Duration(milliseconds: 700);
  static const double _padding = AppSpacing.sm + AppSpacing.xs;
  static const double _valueFontSize = 26;

  TextStyle get _valueStyle => const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: _valueFontSize,
        fontFeatures: [FontFeature.tabularFigures()],
        height: 1.1,
      );

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final light = Color.lerp(accent, Colors.white, 0.55)!;
    final soft = Color.lerp(accent, Colors.white, 0.82)!;

    Widget valueChild;
    if (value == null) {
      valueChild = Text('—', style: _valueStyle);
    } else if (reduceMotion || !animateValue) {
      valueChild = Text(formatScore(value!), style: _valueStyle);
    } else {
      valueChild = Text(formatScore(value!), style: _valueStyle)
          .animate()
          .custom(
            duration: countDuration,
            curve: Curves.easeOutCubic,
            begin: 0,
            end: value!.toDouble(),
            builder: (context, animated, child) {
              return Text(
                formatScore(animated.round()),
                style: _valueStyle,
              );
            },
          );
    }

    final captionText = caption;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [soft, light],
        ),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
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
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 22),
                if (captionText != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.18),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.xl),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            child: Text(
                              captionText,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color:
                                    Color.lerp(accent, Colors.black, 0.35),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: valueChild,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
        .fadeIn(delay: entranceDelay, duration: 280.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          delay: entranceDelay,
          duration: 320.ms,
          curve: Curves.easeOut,
        );
  }
}
