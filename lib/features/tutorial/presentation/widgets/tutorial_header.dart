import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// "HOW TO PLAY" pill, game title, and short subtitle for the tutorial shell.
class TutorialHeader extends StatelessWidget {
  const TutorialHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      height: 1.1,
    );

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppSpacing.xl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            child: Text(
              'HOW TO PLAY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle?.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..strokeJoin = StrokeJoin.round
                  ..color = Colors.black87,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle?.copyWith(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
