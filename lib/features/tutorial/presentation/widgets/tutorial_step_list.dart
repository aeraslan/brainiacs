import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Numbered candy instruction pills for the tutorial shell.
class TutorialStepList extends StatelessWidget {
  const TutorialStepList({
    super.key,
    required this.steps,
    required this.accentColor,
    this.compact = false,
  });

  final List<String> steps;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visibleSteps = compact && steps.length > 2
        ? steps.take(2).toList(growable: false)
        : steps;

    return Column(
      children: [
        for (var i = 0; i < visibleSteps.length; i++) ...[
          if (i > 0)
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          _TutorialStepCard(
            index: i + 1,
            text: visibleSteps[i],
            accentColor: accentColor,
            compact: compact,
          )
              .animate()
              .fadeIn(
                delay: (80 * i).ms,
                duration: 220.ms,
              )
              .slideY(
                begin: 0.18,
                end: 0,
                delay: (80 * i).ms,
                duration: 280.ms,
                curve: Curves.easeOut,
              ),
        ],
      ],
    );
  }
}

class _TutorialStepCard extends StatelessWidget {
  const _TutorialStepCard({
    required this.index,
    required this.text,
    required this.accentColor,
    required this.compact,
  });

  final int index;
  final String text;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: compact ? AppSpacing.sm : AppSpacing.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 1.25,
                ),
              ),
              child: SizedBox(
                width: compact ? 22 : 26,
                height: compact ? 22 : 26,
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: compact ? 12 : 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      fontSize: compact ? 13 : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
