import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

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
  final bool enabled;
  final Map<int, GlobalKey>? digitKeys;

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
            child: _PadButton(
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

        return Column(
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
              _PadButton(
                label: 'C',
                enabled: enabled,
                isClear: true,
                onPressed: onClear,
              ),
            ]),
          ],
        );
      },
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isClear = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isClear;

  List<Color> get _gradientColors {
    if (isClear) {
      return [
        AppColors.incorrect.withValues(alpha: 0.95),
        AppColors.incorrect.withValues(alpha: 0.75),
      ];
    }
    return const [AppColors.padGradientStart, AppColors.padGradientEnd];
  }

  Color get _borderColor => isClear ? AppColors.incorrect : AppColors.padBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isClear ? AppColors.incorrect : AppColors.padGradientEnd,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      elevation: 4,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: _borderColor, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _gradientColors,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.onAccent,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
