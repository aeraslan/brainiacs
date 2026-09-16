import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Animates the final score counting up from 0 to [target].
class ScoreCountUp extends StatelessWidget {
  const ScoreCountUp({
    super.key,
    required this.target,
  });

  final int target;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Final Score',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        RepaintBoundary(
          child: Text(
            '$target',
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(color: AppColors.accent),
          )
              .animate()
              .custom(
                duration: 900.ms,
                curve: Curves.easeOutCubic,
                begin: 0,
                end: target.toDouble(),
                builder: (context, value, child) {
                  return Text(
                    '${value.round()}',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.accent,
                    ),
                  );
                },
              )
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ],
    );
  }
}
