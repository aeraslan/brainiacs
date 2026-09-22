import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'candy_pad_button.dart';

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
  }) {
    return showGeneralDialog<PauseMenuAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss pause menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _PauseMenuOverlay(
          isPracticeMode: isPracticeMode,
          onAction: (action) => Navigator.of(dialogContext).pop(action),
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
    required this.onAction,
  });

  final bool isPracticeMode;
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onAction(PauseMenuAction.resume),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.58),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _PauseMenuCard(
                isPracticeMode: isPracticeMode,
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

class _PauseMenuCard extends StatelessWidget {
  const _PauseMenuCard({
    required this.isPracticeMode,
    required this.onAction,
    required this.darken,
    required this.endPracticeOrange,
  });

  final bool isPracticeMode;
  final ValueChanged<PauseMenuAction> onAction;
  final Color Function(Color) darken;
  final Color endPracticeOrange;

  static const double _buttonHeight = AppSpacing.xxl + AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      _PauseActionButton(
        label: 'Resume',
        color: AppColors.mint,
        darkColor: darken(AppColors.mint),
        onPressed: () => onAction(PauseMenuAction.resume),
        delayMs: 0,
        height: _buttonHeight,
      ),
      if (isPracticeMode)
        _PauseActionButton(
          label: 'End Practice',
          color: AppColors.sunnyYellow,
          darkColor: endPracticeOrange,
          onPressed: () => onAction(PauseMenuAction.endPractice),
          delayMs: 80,
          height: _buttonHeight,
        ),
      _PauseActionButton(
        label: 'Quit to Menu',
        color: AppColors.coral,
        darkColor: darken(AppColors.coral),
        onPressed: () => onAction(PauseMenuAction.quitToMenu),
        delayMs: isPracticeMode ? 160 : 80,
        height: _buttonHeight,
      ),
    ];

    return DecoratedBox(
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
              'Paused',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...buttons.map(
              (button) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: button,
              ),
            ),
          ],
        ),
      ),
    );
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
