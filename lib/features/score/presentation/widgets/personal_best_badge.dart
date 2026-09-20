import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Candy "New Rank Unlocked!" badge shown when the player breaks their record.
class PersonalBestBadge extends StatelessWidget {
  const PersonalBestBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.vibrantPurple,
            AppColors.coral,
            AppColors.sunnyYellow,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x339B5DE5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: AppColors.onAccent,
              size: 18,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'New Rank Unlocked!',
              style: TextStyle(
                color: AppColors.onAccent,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: 1800.ms,
          color: Colors.white.withValues(alpha: 0.55),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}
