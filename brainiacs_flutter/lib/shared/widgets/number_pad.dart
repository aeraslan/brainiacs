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

        return Column(
          children: [
            SizedBox(
              height: cellHeight * 2 + spacing,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: digitButton(7)),
                              const SizedBox(width: spacing),
                              Expanded(child: digitButton(8)),
                              const SizedBox(width: spacing),
                              Expanded(child: digitButton(9)),
                            ],
                          ),
                        ),
                        const SizedBox(height: spacing),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: digitButton(4)),
                              const SizedBox(width: spacing),
                              Expanded(child: digitButton(5)),
                              const SizedBox(width: spacing),
                              Expanded(child: digitButton(6)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: spacing),
                  Expanded(
                    child: _PadButton(
                      label: 'C',
                      enabled: enabled,
                      isClear: true,
                      onPressed: onClear,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: spacing),
            SizedBox(
              height: cellHeight,
              child: Row(
                children: [
                  Expanded(child: digitButton(1)),
                  const SizedBox(width: spacing),
                  Expanded(child: digitButton(2)),
                  const SizedBox(width: spacing),
                  Expanded(child: digitButton(3)),
                  const SizedBox(width: spacing),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
            const SizedBox(height: spacing),
            SizedBox(
              height: cellHeight,
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(flex: 2, child: digitButton(0)),
                  const Spacer(flex: 2),
                ],
              ),
            ),
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
