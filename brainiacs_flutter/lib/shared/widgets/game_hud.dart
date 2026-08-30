import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/session/game_session_notifier.dart';
import 'circular_timer.dart';

class GameHud extends ConsumerWidget {
  const GameHud({super.key, this.isOnLightBackground = false});

  final bool isOnLightBackground;

  Future<void> _showExitDialog(BuildContext context, WidgetRef ref) async {
    final action = await showDialog<_ExitAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Leave game?'),
          content: const Text(
            'End the game to see your score, or return to the main menu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExitAction.endGame),
              child: const Text('End Game'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExitAction.mainMenu),
              child: const Text('Main Menu'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    final session = ref.read(gameSessionProvider.notifier);
    switch (action) {
      case _ExitAction.endGame:
        session.endSessionEarly();
      case _ExitAction.mainMenu:
        session.resetToMenu();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRemaining = ref.watch(
      gameSessionProvider.select((s) => s.timeRemaining),
    );
    final totalScore = ref.watch(
      gameSessionProvider.select((s) => s.totalScore),
    );

    final iconColor = isOnLightBackground
        ? AppColors.textPrimary
        : AppColors.onAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(context, ref),
            tooltip: 'Leave game',
            icon: Icon(Icons.home_rounded, color: iconColor),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface.withValues(alpha: 0.72),
              padding: const EdgeInsets.all(AppSpacing.sm),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircularTimer(timeRemaining: timeRemaining),
          const Spacer(),
          _ScoreDisplay(
            score: totalScore,
            isOnLightBackground: isOnLightBackground,
          ),
        ],
      ),
    );
  }
}

enum _ExitAction {
  endGame,
  mainMenu,
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score, required this.isOnLightBackground});

  final int score;
  final bool isOnLightBackground;

  @override
  Widget build(BuildContext context) {
    final labelColor = isOnLightBackground
        ? AppColors.scoreLabelOnLight
        : AppColors.textSecondary;
    final scoreColor = isOnLightBackground
        ? AppColors.scoreOnLight
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'SCORE',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 12,
            letterSpacing: 1.2,
            color: labelColor,
          ),
        ),
        Text(
          '$score',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: scoreColor),
        ),
      ],
    );
  }
}
