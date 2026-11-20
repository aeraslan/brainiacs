import 'dart:async' show unawaited;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_controller_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/rank/title_tier.dart';
import '../../../../core/rank/title_tier_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/candy_button.dart';
import 'rank_defend_chip.dart';

enum _RevealStage { spinning, landing, result }

/// Candy rank slot-machine reveal that spins then celebrates [earnedTitle].
abstract final class RankRevealDialog {
  static Future<void> show(
    BuildContext context, {
    required TitleTier earnedTitle,
    required RankDefendOutcome? outcome,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: AppLocalizations.of(context).scoreDismissRankReveal,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _RankRevealOverlay(
          earnedTitle: earnedTitle,
          outcome: outcome,
          onDismiss: () => Navigator.of(dialogContext).pop(),
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

class _RankRevealOverlay extends StatefulWidget {
  const _RankRevealOverlay({
    required this.earnedTitle,
    required this.outcome,
    required this.onDismiss,
  });

  final TitleTier earnedTitle;
  final RankDefendOutcome? outcome;
  final VoidCallback onDismiss;

  @override
  State<_RankRevealOverlay> createState() => _RankRevealOverlayState();
}

class _RankRevealOverlayState extends State<_RankRevealOverlay> {
  static const Duration _landingHold = Duration(milliseconds: 600);

  _RevealStage _stage = _RevealStage.spinning;
  int _transitionGeneration = 0;
  bool _dismissed = false;

  void _onLocked() {
    if (_stage != _RevealStage.spinning) {
      return;
    }
    setState(() => _stage = _RevealStage.landing);
    unawaited(_transitionToResult());
  }

  Future<void> _transitionToResult() async {
    final generation = ++_transitionGeneration;
    await Future<void>.delayed(_landingHold);
    if (!mounted ||
        generation != _transitionGeneration ||
        _stage != _RevealStage.landing) {
      return;
    }
    setState(() => _stage = _RevealStage.result);
  }

  void _tryDismiss() {
    if (_stage != _RevealStage.result || _dismissed) {
      return;
    }
    _dismissed = true;
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final showResult = _stage == _RevealStage.result;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tryDismiss,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.58)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
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
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          );
                          return FadeTransition(
                            opacity: curved,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.96,
                                end: 1,
                              ).animate(curved),
                              child: child,
                            ),
                          );
                        },
                        child: showResult
                            ? _ResultStage(
                                key: const ValueKey('result'),
                                earnedTitle: widget.earnedTitle,
                                outcome: widget.outcome,
                                onDismiss: _tryDismiss,
                              )
                            : _RouletteStage(
                                key: const ValueKey('roulette'),
                                earnedTitle: widget.earnedTitle,
                                hasLocked: _stage != _RevealStage.spinning,
                                onLocked: _onLocked,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouletteStage extends StatelessWidget {
  const _RouletteStage({
    super.key,
    required this.earnedTitle,
    required this.hasLocked,
    required this.onLocked,
  });

  final TitleTier earnedTitle;
  final bool hasLocked;
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.scoreYourRank,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _RankSlotMachine(
          earnedTitle: earnedTitle,
          hasLocked: hasLocked,
          onLocked: onLocked,
        ),
      ],
    );
  }
}

class _ResultStage extends StatelessWidget {
  const _ResultStage({
    super.key,
    required this.earnedTitle,
    required this.outcome,
    required this.onDismiss,
  });

  final TitleTier earnedTitle;
  final RankDefendOutcome? outcome;
  final VoidCallback onDismiss;

  String _heading(AppLocalizations l10n) {
    return switch (outcome) {
      RankDefendOutcome.unlocked => l10n.rankRevealPromotionHeading,
      RankDefendOutcome.defended => l10n.rankRevealDefendedHeading,
      RankDefendOutcome.pending || null => l10n.rankRevealSessionHeading,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final light = Color.lerp(earnedTitle.color, Colors.white, 0.35)!;
    final dark = Color.lerp(earnedTitle.color, Colors.black, 0.18)!;
    final isPromotion = outcome == RankDefendOutcome.unlocked;
    final isDefended = outcome == RankDefendOutcome.defended;

    Widget badge = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light, earnedTitle.color, dark],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: earnedTitle.color.withValues(
              alpha: isPromotion ? 0.55 : 0.35,
            ),
            blurRadius: isPromotion ? 28 : 18,
            spreadRadius: isPromotion ? 2 : 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Icon(earnedTitle.icon, color: AppColors.onAccent, size: 40),
      ),
    );

    if (isPromotion) {
      badge = badge
          .animate()
          .scale(
            begin: const Offset(0.6, 0.6),
            end: const Offset(1, 1),
            duration: 420.ms,
            curve: Curves.easeOutBack,
          )
          .shimmer(
            delay: 180.ms,
            duration: 700.ms,
            color: earnedTitle.color.withValues(alpha: 0.45),
          );
    } else if (isDefended) {
      badge = badge.animate().scale(
        begin: const Offset(0.85, 0.85),
        end: const Offset(1, 1),
        duration: 360.ms,
        curve: Curves.easeOut,
      );
    } else {
      badge = badge.animate().fadeIn(duration: 320.ms);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
              _heading(l10n),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: earnedTitle.color,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.6,
              ),
            )
            .animate()
            .fadeIn(duration: 280.ms)
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 320.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: AppSpacing.md),
        badge,
        const SizedBox(height: AppSpacing.md),
        Text(
              earnedTitle.localizedName(l10n),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            )
            .animate()
            .fadeIn(delay: 80.ms, duration: 320.ms)
            .slideY(
              begin: 0.08,
              end: 0,
              delay: 80.ms,
              duration: 320.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: AppSpacing.sm),
        Text(
              earnedTitle.localizedDescription(l10n),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 380.ms)
            .slideY(
              begin: 0.12,
              end: 0,
              delay: 200.ms,
              duration: 380.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
              width: double.infinity,
              child: CandyButton(label: l10n.scoreNice, onPressed: onDismiss),
            )
            .animate()
            .fadeIn(delay: 280.ms, duration: 280.ms)
            .slideY(
              begin: 0.12,
              end: 0,
              delay: 280.ms,
              duration: 320.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}

class _RankSlotMachine extends StatefulWidget {
  const _RankSlotMachine({
    required this.earnedTitle,
    required this.hasLocked,
    required this.onLocked,
  });

  final TitleTier earnedTitle;
  final bool hasLocked;
  final VoidCallback onLocked;

  @override
  State<_RankSlotMachine> createState() => _RankSlotMachineState();
}

class _RankSlotMachineState extends State<_RankSlotMachine>
    with SingleTickerProviderStateMixin {
  static const double _itemExtent = 72;
  static const double _viewportHeight = _itemExtent * 3;

  /// One continuous spin timed to the spin→win combined SFX (~5s).
  static const Duration _spinDuration = Duration(milliseconds: 5000);
  static const int _spinLoops = 4;

  /// Highest at top → lowest at bottom.
  static final List<TitleTier> _ladder = TitleTier.values.reversed.toList();

  late final FixedExtentScrollController _controller;
  AnimationController? _spinController;

  bool _spinStarted = false;
  bool _landingPop = false;
  bool _isDisposed = false;
  int? _lastTickedItem;

  @override
  void initState() {
    super.initState();
    // Start on Dormant Mind so the first visible frame feels like a fresh spin.
    final startIndex = _ladder.indexOf(TitleTier.dormantMind);
    _controller = FixedExtentScrollController(initialItem: startIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSpin());
  }

  /// Waits until the wheel has clients (needed after the first layout frame).
  void _scheduleSpin() {
    if (!mounted || _isDisposed || _spinStarted) {
      return;
    }
    if (!_controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSpin());
      return;
    }
    _startSpin();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _spinController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Positive modulo (Dart's `%` keeps the dividend's sign).
  static int _mod(int value, int modulus) =>
      ((value % modulus) + modulus) % modulus;

  /// Absolute wheel index that shows [tierIndex] after [fromItem], with
  /// [extraLoops] full rotations so the reel always travels forward.
  static int _targetItem({
    required int fromItem,
    required int tierIndex,
    required int itemCount,
    required int extraLoops,
  }) {
    final currentTier = _mod(fromItem, itemCount);
    var steps = tierIndex - currentTier;
    if (steps <= 0) {
      steps += itemCount;
    }
    return fromItem + (extraLoops * itemCount) + steps;
  }

  void _tickHapticForOffset(double itemPosition) {
    if (_isDisposed || widget.hasLocked) {
      return;
    }
    final absoluteIndex = itemPosition.round();
    if (_lastTickedItem != null && absoluteIndex != _lastTickedItem) {
      HapticFeedback.selectionClick();
    }
    _lastTickedItem = absoluteIndex;
  }

  Future<void> _startSpin() async {
    if (!mounted || _isDisposed || _spinStarted || !_controller.hasClients) {
      return;
    }
    _spinStarted = true;

    final audio = ProviderScope.containerOf(
      context,
    ).read(audioControllerProvider.notifier);
    // Combined spin + win clip — let it run through; do not cut on lock.
    audio.playSlotSpin();

    final itemCount = _ladder.length;
    final earnedIndex = _ladder.indexOf(widget.earnedTitle);
    final startItem = _controller.selectedItem.toDouble();
    _lastTickedItem = startItem.round();

    final landItem = _targetItem(
      fromItem: startItem.round(),
      tierIndex: earnedIndex,
      itemCount: itemCount,
      extraLoops: _spinLoops,
    ).toDouble();

    final spinController = AnimationController(
      vsync: this,
      duration: _spinDuration,
    );
    _spinController = spinController;

    // Continuous ease-out: velocity only falls, never restarts between phases.
    final curved = CurvedAnimation(
      parent: spinController,
      curve: const _SlotDecelerationCurve(),
    );

    void applySpin() {
      if (_isDisposed || !_controller.hasClients) {
        return;
      }
      final item = startItem + (landItem - startItem) * curved.value;
      _controller.jumpTo(item * _itemExtent);
      _tickHapticForOffset(item);
    }

    curved.addListener(applySpin);

    try {
      await spinController.forward();
    } catch (_) {
      await audio.stopSlotSpin();
      return;
    } finally {
      curved.removeListener(applySpin);
    }

    if (!mounted || _isDisposed) {
      await audio.stopSlotSpin();
      return;
    }

    // Hard snap: guarantee the selected item maps to earnedTitle (no half-scroll).
    final settled = landItem.round();
    if (_mod(settled, itemCount) != earnedIndex) {
      final corrected = settled - _mod(settled, itemCount) + earnedIndex;
      _controller.jumpToItem(corrected);
    } else {
      _controller.jumpToItem(settled);
    }

    _lockOntoEarned();
  }

  void _lockOntoEarned() {
    HapticFeedback.heavyImpact();
    // Win sting lives inside sfx_slot_spin.mp3 — do not stop or play a second clip.
    setState(() => _landingPop = true);
    widget.onLocked();
  }

  TitleTier? get _adjacentAbove {
    final i = _ladder.indexOf(widget.earnedTitle);
    if (i <= 0) {
      return null;
    }
    return _ladder[i - 1];
  }

  TitleTier? get _adjacentBelow {
    final i = _ladder.indexOf(widget.earnedTitle);
    if (i < 0 || i >= _ladder.length - 1) {
      return null;
    }
    return _ladder[i + 1];
  }

  @override
  Widget build(BuildContext context) {
    final adjacentAbove = widget.hasLocked ? _adjacentAbove : null;
    final adjacentBelow = widget.hasLocked ? _adjacentBelow : null;
    final frameColor = widget.hasLocked
        ? widget.earnedTitle.color.withValues(alpha: 0.45)
        : AppColors.textSecondary.withValues(alpha: 0.18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: SizedBox(
        height: _viewportHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          child: Stack(
            children: [
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: _itemExtent,
                diameterRatio: 1.6,
                perspective: 0.003,
                physics: const NeverScrollableScrollPhysics(),
                childDelegate: ListWheelChildLoopingListDelegate(
                  children: [
                    for (final tier in _ladder)
                      _RankWheelItem(
                        tier: tier,
                        isSpinning: !widget.hasLocked,
                        isEarnedCenter:
                            widget.hasLocked && tier == widget.earnedTitle,
                        isAdjacent:
                            widget.hasLocked &&
                            (tier == adjacentAbove || tier == adjacentBelow),
                        landingPop: _landingPop && tier == widget.earnedTitle,
                      ),
                  ],
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: AppSpacing.md,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xE6F9F9FB), Color(0x00F9F9FB)],
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: AppSpacing.md,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xE6F9F9FB), Color(0x00F9F9FB)],
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: _itemExtent + 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      border: Border.all(color: frameColor, width: 1.5),
                      color: widget.hasLocked
                          ? widget.earnedTitle.color.withValues(alpha: 0.06)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Front-loaded progress so the reel blurs early, then crawls through the
/// final ranks. Velocity is monotonically non-increasing (never speeds up).
class _SlotDecelerationCurve extends Curve {
  const _SlotDecelerationCurve();

  @override
  double transformInternal(double t) {
    // Stronger than easeOutCubic: most distance early, long readable finish.
    // Equivalent to Curves.easeOutQuint.
    final u = 1.0 - t;
    return 1.0 - u * u * u * u * u;
  }
}

class _RankWheelItem extends StatelessWidget {
  const _RankWheelItem({
    required this.tier,
    required this.isSpinning,
    required this.isEarnedCenter,
    required this.isAdjacent,
    required this.landingPop,
  });

  final TitleTier tier;
  final bool isSpinning;
  final bool isEarnedCenter;
  final bool isAdjacent;
  final bool landingPop;

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(tier.color, Colors.white, 0.35)!;
    final dark = Color.lerp(tier.color, Colors.black, 0.18)!;

    final scale = isEarnedCenter ? 1.12 : 1.0;
    final opacity = isSpinning
        ? 1.0
        : isAdjacent
        ? 0.75
        : isEarnedCenter
        ? 1.0
        : 0.7;

    Widget pill = Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.xl),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [light, tier.color, dark],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: isEarnedCenter
                  ? const Color(0xCCFFFFFF)
                  : const Color(0x4DFFFFFF),
              width: isEarnedCenter ? 2 : 1.25,
            ),
            boxShadow: [
              BoxShadow(
                color: tier.color.withValues(
                  alpha: isEarnedCenter ? 0.45 : 0.22,
                ),
                blurRadius: isEarnedCenter ? 16 : 10,
                spreadRadius: isEarnedCenter ? 1 : 0,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.xl - 2),
                border: Border.all(color: const Color(0x59FFFFFF), width: 1.25),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tier.icon,
                      color: AppColors.onAccent,
                      size: isEarnedCenter ? 24 : 20,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tier.localizedName(context.l10n),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            color: AppColors.onAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: isEarnedCenter ? 17 : 15,
                            letterSpacing: 0.2,
                            shadows: const [
                              Shadow(
                                color: Color(0x33000000),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (landingPop) {
      pill = pill
          .animate()
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1, 1),
            duration: 520.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 180.ms);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: pill,
      ),
    );
  }
}
