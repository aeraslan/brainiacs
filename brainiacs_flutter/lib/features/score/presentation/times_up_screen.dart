import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';

class TimesUpScreen extends ConsumerWidget {
  const TimesUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalScore = ref.watch(
      gameSessionProvider.select((state) => state.totalScore),
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                    "Time's Up!",
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium,
                  )
                  .animate()
                  .fadeIn(duration: 180.ms)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    duration: 320.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Score',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$totalScore',
                textAlign: TextAlign.center,
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
