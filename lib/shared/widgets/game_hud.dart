import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/session/game_session_notifier.dart';
import 'candy_pad_button.dart';
import 'circular_timer.dart';
import 'pause_menu_dialog.dart';

class GameHud extends ConsumerWidget {
  const GameHud({super.key, this.isOnLightBackground = false});

  final bool isOnLightBackground;

  static const double _timerSize = 72;
  static const double _pauseSize = AppSpacing.xxl;

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  Future<void> _showPauseMenu(BuildContext context, WidgetRef ref) async {
    final session = ref.read(gameSessionProvider.notifier);
    final isPracticeMode = ref.read(
      gameSessionProvider.select((s) => s.isPracticeMode),
    );

    session.pauseGame();

    final action = await PauseMenuDialog.show(
      context,
      isPracticeMode: isPracticeMode,
    );

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case PauseMenuAction.resume:
      case null:
        session.resumeGame();
      case PauseMenuAction.endPractice:
        session.endSessionEarly();
      case PauseMenuAction.quitToMenu:
        session.resetToMenu();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: _timerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                _PauseButton(
                  size: _pauseSize,
                  onPressed: () => _showPauseMenu(context, ref),
                  darken: _darken,
                ),
                const Spacer(),
                _ScorePill(isOnLightBackground: isOnLightBackground),
              ],
            ),
            const _CenteredTimer(size: _timerSize),
          ],
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.size,
    required this.onPressed,
    required this.darken,
  });

  final double size;
  final VoidCallback onPressed;
  final Color Function(Color) darken;

  @override
  Widget build(BuildContext context) {
    final dark = darken(AppColors.electricBlue);
    return SizedBox(
      width: size,
      height: size,
      child: CandyPadButton(
        label: '',
        borderRadius: size / 2,
        gradientColors: [AppColors.electricBlue, dark],
        borderColor: dark,
        onPressed: onPressed,
        child: const Icon(
          Icons.pause_rounded,
          color: AppColors.onAccent,
          size: AppSpacing.lg,
        ),
      ),
    );
  }
}

class _CenteredTimer extends ConsumerWidget {
  const _CenteredTimer({required this.size});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRemaining = ref.watch(
      gameSessionProvider.select((s) => s.timeRemaining),
    );
    return IgnorePointer(
      child: CircularTimer(timeRemaining: timeRemaining, size: size),
    );
  }
}

class _ScorePill extends ConsumerWidget {
  const _ScorePill({required this.isOnLightBackground});

  final bool isOnLightBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(gameSessionProvider.select((s) => s.totalScore));
    final scoreColor = isOnLightBackground
        ? AppColors.scoreOnLight
        : AppColors.onAccent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.sunnyYellow,
              size: AppSpacing.lg,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
