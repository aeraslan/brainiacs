import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/color_clash_round.dart';

/// Glossy pill showing the active Stroop rule; pulses when the rule changes.
class StroopRulePill extends StatelessWidget {
  const StroopRulePill({
    super.key,
    required this.rule,
    this.emphasized = false,
  });

  final StroopRule rule;
  final bool emphasized;

  String get _label => switch (rule) {
        StroopRule.matchColor => 'Match the COLOR!',
        StroopRule.matchText => 'Read the TEXT!',
      };

  @override
  Widget build(BuildContext context) {
    final borderColor = emphasized
        ? AppColors.electricBlue
        : const Color(0xFF2B2D42);
    final borderWidth = emphasized ? 3.0 : 2.0;

    Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCCFFFFFF),
            Color(0xE6FFFFFF),
            Color(0xB3E8F4FA),
          ],
          stops: [0.0, 0.35, 1.0],
        ),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          const BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
          if (emphasized)
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          _label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );

    pill = KeyedSubtree(
      key: ValueKey(rule),
      child: pill
          .animate()
          .scale(
            begin: const Offset(0.88, 0.88),
            end: const Offset(1, 1),
            duration: 320.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 200.ms),
    );

    if (emphasized) {
      pill = KeyedSubtree(
        key: const ValueKey('rule-emphasized'),
        child: pill
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.08, 1.08),
              duration: 400.ms,
              curve: Curves.easeInOut,
            ),
      );
    }

    return pill;
  }
}
