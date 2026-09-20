import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/candy_pad_button.dart';
import '../../domain/color_clash_round.dart';

enum StroopPadFeedback { none, correct, incorrect }

/// 2×2 glossy candy pad for Color Clash answer choices.
class StroopChoicePad extends StatelessWidget {
  const StroopChoicePad({
    super.key,
    required this.choices,
    required this.usesTextOptions,
    required this.onSelected,
    this.enabled = true,
    this.selectedIdentityId,
    this.feedback = StroopPadFeedback.none,
    this.hintIdentityId,
    this.choiceKeys,
  });

  final List<StroopChoice> choices;
  final bool usesTextOptions;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String? selectedIdentityId;
  final StroopPadFeedback feedback;

  /// Tutorial-only glow on the correct option after a wrong demo tap.
  final String? hintIdentityId;
  final Map<String, GlobalKey>? choiceKeys;

  static const double _lockedOpacity = 0.7;
  static const double _widthFactor = 0.92;
  static const double _heightFactor = 0.88;
  static const double _maxCellAspect = 1.2;

  static const List<Color> _textOptionGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF2F2F2),
  ];
  static const Color _textOptionBorder = Color(0xFF2B2D42);

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0)).toColor();
  }

  static Color _lighten(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (choices.isEmpty) {
          return const SizedBox.shrink();
        }

        const spacing = AppSpacing.md;
        final usableWidth = constraints.maxWidth * _widthFactor;
        final usableHeight = constraints.maxHeight * _heightFactor;

        var cellWidth = (usableWidth - spacing) / 2;
        var cellHeight = (usableHeight - spacing) / 2;

        if (cellWidth > cellHeight * _maxCellAspect) {
          cellWidth = cellHeight * _maxCellAspect;
        } else if (cellHeight > cellWidth * _maxCellAspect) {
          cellHeight = cellWidth * _maxCellAspect;
        }

        cellWidth = math.max(0, cellWidth);
        cellHeight = math.max(0, cellHeight);

        final gridWidth = cellWidth * 2 + spacing;
        final gridHeight = cellHeight * 2 + spacing;

        Widget button(StroopChoice choice) {
          final isSelected = selectedIdentityId == choice.identityId;
          final isHinted = hintIdentityId == choice.identityId;
          final List<Color> gradientColors;
          final Color borderColor;

          if (isSelected && feedback == StroopPadFeedback.correct) {
            gradientColors = const [
              AppColors.correct,
              AppColors.correct,
            ];
            borderColor = _darken(AppColors.correct);
          } else if (isSelected && feedback == StroopPadFeedback.incorrect) {
            gradientColors = const [
              AppColors.incorrect,
              AppColors.incorrect,
            ];
            borderColor = _darken(AppColors.incorrect);
          } else if (usesTextOptions) {
            gradientColors = _textOptionGradient;
            borderColor = _textOptionBorder;
          } else {
            final base = choice.paintColor;
            gradientColors = [_lighten(base), base];
            borderColor = _darken(base);
          }

          final child = usesTextOptions
              ? Text(
                  choice.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: choice.paintColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 1,
                  ),
                )
              : null;

          Widget pad = CandyPadButton(
            label: usesTextOptions ? choice.label : '',
            enabled: enabled,
            gradientColors: gradientColors,
            borderColor: borderColor,
            fontSize: usesTextOptions ? 28 : null,
            fontWeight: FontWeight.w900,
            onPressed: () => onSelected(choice.identityId),
            child: child,
          );

          if (isHinted) {
            pad = Stack(
              fit: StackFit.expand,
              children: [
                pad,
                const IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xE62B2D42),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.check_rounded,
                          size: 36,
                          color: AppColors.onAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
                .animate(
                  key: const ValueKey('stroop-correct-hint'),
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.06, 1.06),
                  duration: 420.ms,
                  curve: Curves.easeInOut,
                );
          }

          final dimOthers = hintIdentityId != null && !isHinted && !isSelected;
          return SizedBox(
            key: choiceKeys?[choice.identityId],
            width: cellWidth,
            height: cellHeight,
            child: Opacity(
              opacity: enabled || isSelected || isHinted
                  ? 1
                  : (dimOthers ? 0.38 : _lockedOpacity),
              child: pad,
            ),
          );
        }

        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: Column(
              children: [
                Row(
                  children: [
                    button(choices[0]),
                    const SizedBox(width: spacing),
                    button(choices[1]),
                  ],
                ),
                const SizedBox(height: spacing),
                Row(
                  children: [
                    button(choices[2]),
                    const SizedBox(width: spacing),
                    button(choices[3]),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
