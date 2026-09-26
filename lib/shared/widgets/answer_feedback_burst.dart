import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Punchy wrong-answer shake shared by feedback burst, cards, and asteroids.
abstract final class WrongAnswerShake {
  static const Duration duration = Duration(milliseconds: 200);
  static const double amount = 6;
  /// One oscillation over [duration] so the punch reads as a single tilt.
  static const double hz = 5;
  static const Curve curve = Curves.easeOut;
}

/// One-shot correct/wrong juice on the answer display, driven by Riverpod tokens.
///
/// - Correct (default): pop/bounce + shimmer + tint on [child] + floating "+points"
/// - Correct ([successOverlay]): leave [child] untouched; show overlay (e.g. checkmark)
/// - Wrong: punchy shakeX + optional red border flash + floating penalty dropping down
///
/// Pass a stable [contentKey] for the current question so leftover juice is
/// dropped immediately when the next puzzle appears.
class AnswerFeedbackBurst extends StatefulWidget {
  const AnswerFeedbackBurst({
    super.key,
    required this.child,
    required this.contentKey,
    this.successToken = 0,
    this.errorToken = 0,
    this.points = 100,
    this.penalty = -20,
    this.applySuccessEffectsToChild = true,
    this.applyErrorEffectsToChild = true,
    this.applyErrorTint = true,
    this.showErrorBorder = true,
    this.errorShakeAmount,
    this.successOverlay,
  });

  final Widget child;
  final Object contentKey;
  final int successToken;
  final int errorToken;
  final int points;
  final int penalty;

  /// When false, success juice does not scale/tint [child] (use [successOverlay]).
  final bool applySuccessEffectsToChild;

  /// When false, wrong juice does not shake/tint [child] (avoids remounting
  /// boards that own their own tilt animations).
  final bool applyErrorEffectsToChild;

  /// When false, wrong shake does not tint [child] (e.g. Stroop color must stay).
  final bool applyErrorTint;

  /// When false, skips the red border flash around [child].
  final bool showErrorBorder;

  /// Overrides [WrongAnswerShake.amount] for a more/less pronounced punch.
  final double? errorShakeAmount;

  /// Optional overlay shown on success (e.g. a large checkmark). Centered in stack.
  final Widget? successOverlay;

  @override
  State<AnswerFeedbackBurst> createState() => _AnswerFeedbackBurstState();
}

class _AnswerFeedbackBurstState extends State<AnswerFeedbackBurst> {
  int? _playingSuccessToken;
  int? _playingErrorToken;

  @override
  void didUpdateWidget(AnswerFeedbackBurst oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.contentKey != oldWidget.contentKey) {
      _playingSuccessToken = null;
      _playingErrorToken = null;
    }

    if (widget.successToken != oldWidget.successToken &&
        widget.successToken > 0) {
      _playingSuccessToken = widget.successToken;
      _playingErrorToken = null;
    }

    if (widget.errorToken != oldWidget.errorToken && widget.errorToken > 0) {
      _playingErrorToken = widget.errorToken;
      _playingSuccessToken = null;
    }
  }

  void _onSuccessComplete() {
    if (!mounted || _playingSuccessToken == null) {
      return;
    }
    setState(() => _playingSuccessToken = null);
  }

  @override
  Widget build(BuildContext context) {
    final successToken = _playingSuccessToken;
    final errorToken = _playingErrorToken;

    Widget content = KeyedSubtree(
      key: ValueKey(widget.contentKey),
      child: widget.child,
    );

    if (successToken != null && widget.applySuccessEffectsToChild) {
      content = content
          .animate(
            key: ValueKey('correct-burst-$successToken'),
            onComplete: (_) => _onSuccessComplete(),
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.12, 1.12),
            duration: 220.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .scale(
            begin: const Offset(1.12, 1.12),
            end: const Offset(1, 1),
            duration: 160.ms,
            curve: Curves.easeOut,
          )
          .shimmer(
            duration: 280.ms,
            color: Colors.white.withValues(alpha: 0.85),
          )
          .tint(color: AppColors.correct, duration: 180.ms);
    } else if (errorToken != null && widget.applyErrorEffectsToChild) {
      // Keep the animate wrapper until [contentKey] changes so child widgets
      // (scales, Stroop word) are not remounted mid-feedback.
      var wrong = content
          .animate(key: ValueKey('wrong-burst-$errorToken'))
          .shakeX(
            amount: widget.errorShakeAmount ?? WrongAnswerShake.amount,
            duration: WrongAnswerShake.duration,
            hz: WrongAnswerShake.hz,
            curve: WrongAnswerShake.curve,
          );
      if (widget.applyErrorTint) {
        wrong = wrong.tint(
          color: AppColors.incorrect.withValues(alpha: 0.35),
          duration: WrongAnswerShake.duration,
        );
      }
      content = wrong;
    }

    final overlay = widget.successOverlay;
    final showSuccessOverlay =
        successToken != null && overlay != null && !widget.applySuccessEffectsToChild;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        content,
        if (errorToken != null && widget.showErrorBorder)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: AppColors.incorrect.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
              )
                  .animate(key: ValueKey('wrong-border-$errorToken'))
                  .fadeIn(duration: 40.ms)
                  .then(delay: 80.ms)
                  .fadeOut(duration: 80.ms),
            ),
          ),
        if (showSuccessOverlay)
          IgnorePointer(
            child: overlay
                .animate(
                  key: ValueKey('correct-overlay-$successToken'),
                  onComplete: (_) => _onSuccessComplete(),
                )
                .fadeIn(duration: 80.ms)
                .scale(
                  begin: const Offset(0.35, 0.35),
                  end: const Offset(1, 1),
                  duration: 320.ms,
                  curve: Curves.easeOutBack,
                )
                .then(delay: 120.ms)
                .fadeOut(duration: 180.ms),
          ),
        if (successToken != null)
          Positioned(
            top: -AppSpacing.lg,
            child: IgnorePointer(
              child: _FloatingScoreText(
                label: '+${widget.points}',
                color: AppColors.scoreGold,
                animationKey: ValueKey('float-score-$successToken'),
                slideEnd: -1.4,
                popScale: true,
              ),
            ),
          ),
        if (errorToken != null)
          Positioned(
            bottom: -AppSpacing.sm,
            child: IgnorePointer(
              child: _FloatingScoreText(
                label: '${widget.penalty}',
                color: AppColors.incorrect,
                animationKey: ValueKey('float-penalty-$errorToken'),
                slideEnd: 1.2,
                duration: 500.ms,
              ),
            ),
          ),
      ],
    );
  }
}

class _FloatingScoreText extends StatelessWidget {
  const _FloatingScoreText({
    required this.label,
    required this.color,
    required this.animationKey,
    required this.slideEnd,
    this.duration,
    this.popScale = false,
  });

  final String label;
  final Color color;
  final Key animationKey;
  final double slideEnd;
  final Duration? duration;
  final bool popScale;

  @override
  Widget build(BuildContext context) {
    final slideDuration = duration ?? 450.ms;

    Widget text = Text(
      label,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
    );

    if (popScale) {
      return text
          .animate(key: animationKey)
          .fadeIn(duration: 60.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.2, 1.2),
            duration: 180.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
            duration: 100.ms,
            curve: Curves.easeOut,
          )
          .slideY(
            begin: 0,
            end: slideEnd,
            duration: slideDuration,
            curve: Curves.easeOut,
          )
          .fadeOut(
            delay: slideDuration * 0.25,
            duration: slideDuration * 0.7,
          );
    }

    return text
        .animate(key: animationKey)
        .fadeIn(duration: 60.ms)
        .slideY(
          begin: 0,
          end: slideEnd,
          duration: slideDuration,
          curve: Curves.easeOut,
        )
        .fadeOut(
          delay: slideDuration * 0.25,
          duration: slideDuration * 0.7,
        );
  }
}
