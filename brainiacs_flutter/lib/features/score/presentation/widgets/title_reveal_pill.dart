import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/rank/title_tier.dart';

/// Glossy candy pill that reveals the title earned this session.
class TitleRevealPill extends StatelessWidget {
  const TitleRevealPill({
    super.key,
    required this.tier,
    this.revealDelay = const Duration(milliseconds: 900),
  });

  final TitleTier tier;
  final Duration revealDelay;

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(tier.color, Colors.white, 0.35)!;
    final dark = Color.lerp(tier.color, Colors.black, 0.18)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light, tier.color, dark],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: const Color(0x66FFFFFF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.xl - 2),
            border: Border.all(
              color: const Color(0x59FFFFFF),
              width: 1.25,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tier.icon,
                  color: AppColors.onAccent,
                  size: 28,
                  shadows: const [
                    Shadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    tier.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.onAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
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
          delay: revealDelay,
          duration: 280.ms,
        )
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1, 1),
          delay: revealDelay,
          duration: 520.ms,
          curve: Curves.easeOutBack,
        );
  }
}
