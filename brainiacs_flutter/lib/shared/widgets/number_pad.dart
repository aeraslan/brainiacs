import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'candy_pad_button.dart';

/// Shared candy-style digit pad. Error juice lives elsewhere (e.g. score HUD);
/// this widget only provides glossy keys, press pop, and a lockout dim.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onClear,
    this.enabled = true,
    this.digitKeys,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onClear;

  /// When false (parent feedback lockout), ignores taps and dims to 0.7.
  final bool enabled;
  final Map<int, GlobalKey>? digitKeys;

  static const double _lockedOpacity = 0.7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        const rows = 4;
        final cellHeight =
            (constraints.maxHeight - spacing * (rows - 1)) / rows;

        Widget digitButton(int digit) {
          return KeyedSubtree(
            key: digitKeys?[digit],
            child: CandyPadButton(
              label: '$digit',
              enabled: enabled,
              onPressed: () => onDigit(digit),
            ),
          );
        }

        Widget row(List<Widget> children) {
          return SizedBox(
            height: cellHeight,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: spacing),
                  Expanded(child: children[i]),
                ],
              ],
            ),
          );
        }

        final pad = Column(
          children: [
            row([digitButton(1), digitButton(2), digitButton(3)]),
            const SizedBox(height: spacing),
            row([digitButton(4), digitButton(5), digitButton(6)]),
            const SizedBox(height: spacing),
            row([digitButton(7), digitButton(8), digitButton(9)]),
            const SizedBox(height: spacing),
            row([
              const SizedBox.shrink(),
              digitButton(0),
              CandyPadButton(
                label: 'C',
                enabled: enabled,
                gradientColors: [
                  AppColors.incorrect.withValues(alpha: 0.95),
                  AppColors.incorrect.withValues(alpha: 0.75),
                ],
                borderColor: AppColors.incorrect,
                onPressed: onClear,
              ),
            ]),
          ],
        );

        return Opacity(opacity: enabled ? 1 : _lockedOpacity, child: pad);
      },
    );
  }
}
