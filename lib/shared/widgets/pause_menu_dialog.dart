import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_controller_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/localization/l10n_extension.dart';
import '../../core/session/game_session_state.dart';
import 'candy_pad_button.dart';
import 'candy_switch_row.dart';

enum PauseMenuAction {
  resume,
  endPractice,
  quitToMenu,
}

/// Premium blurred pause overlay with chunky candy action buttons.
abstract final class PauseMenuDialog {
  static Future<PauseMenuAction?> show(
    BuildContext context, {
    required bool isPracticeMode,
    PauseOrigin pauseOrigin = PauseOrigin.manual,
    int manualPauseNumber = 1,
    int pendingPenaltySeconds = 0,
  }) {
    return showGeneralDialog<PauseMenuAction>(
      context: context,
      barrierDismissible: false,
      barrierLabel: context.l10n.pauseDismiss,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return PopScope(
          canPop: false,
          child: _PauseMenuOverlay(
            isPracticeMode: isPracticeMode,
            pauseOrigin: pauseOrigin,
            manualPauseNumber: manualPauseNumber,
            pendingPenaltySeconds: pendingPenaltySeconds,
            onAction: (action) => Navigator.of(dialogContext).pop(action),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _PauseMenuOverlay extends StatelessWidget {
  const _PauseMenuOverlay({
    required this.isPracticeMode,
    required this.pauseOrigin,
    required this.manualPauseNumber,
    required this.pendingPenaltySeconds,
    required this.onAction,
  });

  final bool isPracticeMode;
  final PauseOrigin pauseOrigin;
  final int manualPauseNumber;
  final int pendingPenaltySeconds;
  final ValueChanged<PauseMenuAction> onAction;

  static const Color _endPracticeOrange = Color(0xFFFFA726);

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.58),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _PauseMenuCard(
                isPracticeMode: isPracticeMode,
                pauseOrigin: pauseOrigin,
                manualPauseNumber: manualPauseNumber,
                pendingPenaltySeconds: pendingPenaltySeconds,
                onAction: onAction,
                darken: _darken,
                endPracticeOrange: _endPracticeOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseMenuCard extends ConsumerWidget {
  const _PauseMenuCard({
    required this.isPracticeMode,
    required this.pauseOrigin,
    required this.manualPauseNumber,
    required this.pendingPenaltySeconds,
    required this.onAction,
    required this.darken,
    required this.endPracticeOrange,
  });

  final bool isPracticeMode;
  final PauseOrigin pauseOrigin;
  final int manualPauseNumber;
  final int pendingPenaltySeconds;
  final ValueChanged<PauseMenuAction> onAction;
  final Color Function(Color) darken;
  final Color endPracticeOrange;

  static const double _buttonHeight = AppSpacing.xxl + AppSpacing.sm;

  String _penaltyMessage(BuildContext context) {
    final l10n = context.l10n;
    if (pauseOrigin == PauseOrigin.automatic) {
      return l10n.pausePenaltyAutomatic;
    }
    if (manualPauseNumber <= 1 || pendingPenaltySeconds <= 0) {
      return l10n.pausePenaltyFirstFree;
    }
    return l10n.pausePenaltyResuming(pendingPenaltySeconds);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height -
        mediaQuery.padding.vertical -
        (AppSpacing.lg * 2);

    final resumeButton = _PauseActionButton(
      label: l10n.pauseResume,
      color: AppColors.mint,
      darkColor: darken(AppColors.mint),
      onPressed: () => onAction(PauseMenuAction.resume),
      delayMs: 0,
      height: _buttonHeight,
    );

    final trailingButtons = <Widget>[
      if (isPracticeMode)
        _PauseActionButton(
          label: l10n.pauseEndPractice,
          color: AppColors.sunnyYellow,
          darkColor: endPracticeOrange,
          onPressed: () => onAction(PauseMenuAction.endPractice),
          delayMs: 80,
          height: _buttonHeight,
        ),
      _PauseActionButton(
        label: l10n.pauseQuitToMenu,
        color: AppColors.coral,
        darkColor: darken(AppColors.coral),
        onPressed: () => onAction(PauseMenuAction.quitToMenu),
        delayMs: isPracticeMode ? 160 : 80,
        height: _buttonHeight,
      ),
    ];

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.xl),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AppColors.surfaceElevated],
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.pauseTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _PauseAudioSection(),
                        const SizedBox(height: AppSpacing.md),
                        resumeButton,
                        const SizedBox(height: AppSpacing.sm),
                        _PausePenaltyHint(message: _penaltyMessage(context)),
                        const SizedBox(height: AppSpacing.sm),
                        ...trailingButtons.map(
                          (button) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: button,
                          ),
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
    );
  }
}

class _PausePenaltyHint extends StatelessWidget {
  const _PausePenaltyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.left,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseAudioSection extends ConsumerWidget {
  const _PauseAudioSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final audio = ref.watch(audioControllerProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(
          color: AppColors.electricBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          CandySwitchRow(
            icon: Icons.music_note_rounded,
            label: l10n.pauseMusic,
            value: audio.bgmEnabled,
            compact: true,
            onChanged: (enabled) {
              ref.read(audioControllerProvider.notifier).setBgmEnabled(enabled);
            },
          ),
          CandySwitchRow(
            icon: Icons.volume_up_rounded,
            label: l10n.pauseSoundEffects,
            value: audio.sfxEnabled,
            compact: true,
            onChanged: (enabled) {
              ref.read(audioControllerProvider.notifier).setSfxEnabled(enabled);
            },
          ),
        ],
      ),
    )
        .animate(delay: 40.ms)
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.08, end: 0, duration: 260.ms, curve: Curves.easeOut);
  }
}

class _PauseActionButton extends StatelessWidget {
  const _PauseActionButton({
    required this.label,
    required this.color,
    required this.darkColor,
    required this.onPressed,
    required this.delayMs,
    required this.height,
  });

  final String label;
  final Color color;
  final Color darkColor;
  final VoidCallback onPressed;
  final int delayMs;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CandyPadButton(
        label: label,
        gradientColors: [color, darkColor],
        borderColor: darkColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        onPressed: onPressed,
      ),
    )
        .animate(delay: delayMs.ms)
        .slideY(begin: 0.15, end: 0, duration: 280.ms, curve: Curves.easeOut)
        .fadeIn(duration: 220.ms);
  }
}
