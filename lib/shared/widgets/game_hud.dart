import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/session/active_puzzle_reroll.dart';
import '../../core/session/game_session_notifier.dart';
import '../../core/session/game_session_state.dart';
import 'candy_pad_button.dart';
import 'circular_timer.dart';
import 'pause_menu_dialog.dart';

class GameHud extends ConsumerWidget {
  const GameHud({super.key, this.isOnLightBackground = false});

  final bool isOnLightBackground;

  static const double _timerSize = 72;
  static const double _homeSize = AppSpacing.xxl;

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  Future<void> _showHomeMenu(BuildContext context, WidgetRef ref) async {
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
        if (ref.read(gameSessionProvider).phase == GamePhase.playing) {
          rerollActivePuzzle(ref);
        }
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
                _HomeButton(
                  size: _homeSize,
                  onPressed: () => _showHomeMenu(context, ref),
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

class _HomeButton extends StatelessWidget {
  const _HomeButton({
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
          Icons.home_rounded,
          color: AppColors.onAccent,
          size: AppSpacing.lg,
        ),
      ),
    );
  }
}

class _CenteredTimer extends ConsumerStatefulWidget {
  const _CenteredTimer({required this.size});

  final double size;

  @override
  ConsumerState<_CenteredTimer> createState() => _CenteredTimerState();
}

class _CenteredTimerState extends ConsumerState<_CenteredTimer> {
  int? _playingPenaltyToken;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      gameSessionProvider.select((s) => s.timePenaltyToken),
      (previous, next) {
        if (next > 0 && next != previous) {
          setState(() => _playingPenaltyToken = next);
        }
      },
    );

    final timeRemaining = ref.watch(
      gameSessionProvider.select((s) => s.timeRemaining),
    );
    final size = widget.size;

    return IgnorePointer(
      child: SizedBox(
        width: size + AppSpacing.xxl,
        height: size + AppSpacing.lg,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CircularTimer(timeRemaining: timeRemaining, size: size),
            if (_playingPenaltyToken != null)
              Positioned(
                right: 0,
                top: 0,
                child: _TimePenaltyFlash(
                  key: ValueKey('time-penalty-$_playingPenaltyToken'),
                  label:
                      '-${GameSessionState.pauseTimePenaltySeconds}s',
                  onComplete: () {
                    if (!mounted) {
                      return;
                    }
                    setState(() => _playingPenaltyToken = null);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimePenaltyFlash extends StatelessWidget {
  const _TimePenaltyFlash({
    super.key,
    required this.label,
    required this.onComplete,
  });

  final String label;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.incorrect,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
    )
        .animate(
          onComplete: (_) => onComplete(),
        )
        .fadeIn(duration: 60.ms)
        .slideY(
          begin: 0.2,
          end: -0.8,
          duration: 500.ms,
          curve: Curves.easeOut,
        )
        .fadeOut(delay: 180.ms, duration: 320.ms);
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
