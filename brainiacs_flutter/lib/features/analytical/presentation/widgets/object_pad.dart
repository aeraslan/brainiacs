import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/candy_pad_button.dart';
import 'balance_object_image.dart';

enum ObjectPadFeedback { none, correct, incorrect }

/// Horizontal row of 3–4 candy buttons showing object image answer choices.
class ObjectPad extends StatelessWidget {
  const ObjectPad({
    super.key,
    required this.choices,
    required this.onSelected,
    this.enabled = true,
    this.selectedObjectId,
    this.feedback = ObjectPadFeedback.none,
    this.choiceKeys,
  });

  final List<String> choices;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String? selectedObjectId;
  final ObjectPadFeedback feedback;
  final Map<String, GlobalKey>? choiceKeys;

  static const double _lockedOpacity = 0.7;
  static const double _widthFactor = 0.92;
  static const double _heightFactor = 0.72;
  static const double _maxCellAspect = 1.15;
  static const double _imageSizeFactor = 0.55;

  static const List<Color> _whiteGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF2F2F2),
  ];
  static const Color _whiteBorder = Color(0xFF2B2D42);

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = choices.length;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        const spacing = AppSpacing.md;
        var cellWidth =
            (constraints.maxWidth * _widthFactor - spacing * (count - 1)) /
            count;
        var cellHeight = constraints.maxHeight * _heightFactor;

        if (cellWidth > cellHeight * _maxCellAspect) {
          cellWidth = cellHeight * _maxCellAspect;
        } else if (cellWidth < cellHeight) {
          cellHeight = cellWidth;
        }

        cellWidth = math.max(0, cellWidth);
        cellHeight = math.max(0, cellHeight);

        final padWidth = cellWidth * count + spacing * (count - 1);
        final imageSize =
            math.min(cellWidth, cellHeight) * _imageSizeFactor;

        Widget button(String objectId, int index) {
          final isSelected = selectedObjectId == objectId;
          final List<Color> gradientColors;
          final Color borderColor;

          if (isSelected && feedback == ObjectPadFeedback.correct) {
            gradientColors = [
              AppColors.correct.withValues(alpha: 0.2),
              Colors.white,
            ];
            borderColor = _darken(AppColors.correct);
          } else if (isSelected && feedback == ObjectPadFeedback.incorrect) {
            gradientColors = [
              AppColors.incorrect.withValues(alpha: 0.2),
              Colors.white,
            ];
            borderColor = _darken(AppColors.incorrect);
          } else {
            gradientColors = _whiteGradient;
            borderColor = _whiteBorder;
          }

          return KeyedSubtree(
            key: choiceKeys?[objectId],
            child: SizedBox(
              width: cellWidth,
              height: cellHeight,
              child: CandyPadButton(
                label: objectId,
                enabled: enabled,
                gradientColors: gradientColors,
                borderColor: borderColor,
                onPressed: () => onSelected(objectId),
                child: BalanceObjectImage(
                  assetPath: objectId,
                  size: imageSize,
                ),
              ),
            ),
          );
        }

        final pad = SizedBox(
          width: padWidth,
          height: cellHeight,
          child: Row(
            children: [
              for (var i = 0; i < choices.length; i++) ...[
                if (i > 0) const SizedBox(width: spacing),
                button(choices[i], i),
              ],
            ],
          ),
        );

        return Opacity(
          opacity: enabled ? 1 : _lockedOpacity,
          child: Align(alignment: Alignment.center, child: pad),
        );
      },
    );
  }
}
