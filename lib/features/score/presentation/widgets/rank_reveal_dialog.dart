import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/rank/title_tier.dart';
import '../../../../shared/widgets/candy_button.dart';

/// Candy rank slot-machine reveal that spins then locks onto [earnedTitle].
abstract final class RankRevealDialog {
  static Future<void> show(
    BuildContext context, {
    required TitleTier earnedTitle,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss rank reveal',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _RankRevealOverlay(
          earnedTitle: earnedTitle,
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
    required this.onDismiss,
  });

  final TitleTier earnedTitle;
  final VoidCallback onDismiss;

  @override
  State<_RankRevealOverlay> createState() => _RankRevealOverlayState();
}

class _RankRevealOverlayState extends State<_RankRevealOverlay> {
  bool _hasLocked = false;

  void _onLocked() {
    if (_hasLocked) {
      return;
    }
    setState(() => _hasLocked = true);
  }

  void _tryDismiss() {
    if (!_hasLocked) {
      return;
    }
    widget.onDismiss();
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
            onTap: _tryDismiss,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.58)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _RankRevealCard(
                earnedTitle: widget.earnedTitle,
                hasLocked: _hasLocked,
                onLocked: _onLocked,
                onDismiss: _tryDismiss,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRevealCard extends StatelessWidget {
  const _RankRevealCard({
    required this.earnedTitle,
    required this.hasLocked,
    required this.onLocked,
    required this.onDismiss,
  });

  final TitleTier earnedTitle;
  final bool hasLocked;
  final VoidCallback onLocked;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
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
              'Your Rank',
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
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
                  width: double.infinity,
                  child: Opacity(
                    opacity: hasLocked ? 1 : 0.45,
                    child: CandyButton(label: 'Nice!', onPressed: onDismiss),
                  ),
                )
                .animate(target: hasLocked ? 1 : 0)
                .fadeIn(duration: 220.ms)
                .slideY(
                  begin: 0.12,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
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
  static const double _viewportHeight = _itemExtent * 3.5;

  /// One continuous spin: fast blur → smooth decelerate → readable crawl.
  static const Duration _spinDuration = Duration(milliseconds: 5200);
  static const int _spinLoops = 5;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSpin());
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
      return;
    } finally {
      curved.removeListener(applySpin);
    }

    if (!mounted || _isDisposed) {
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

    return SizedBox(
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
              height: AppSpacing.xl,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: AppSpacing.xl,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [AppColors.surfaceElevated, Color(0x00F9F9FB)],
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
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
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

    final scale = isEarnedCenter ? 1.2 : 1.0;
    final opacity = isSpinning
        ? 1.0
        : isAdjacent
        ? 0.5
        : isEarnedCenter
        ? 1.0
        : 0.85;

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
                  : const Color(0x66FFFFFF),
              width: isEarnedCenter ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: tier.color.withValues(
                  alpha: isEarnedCenter ? 0.55 : 0.28,
                ),
                blurRadius: isEarnedCenter ? 22 : 12,
                spreadRadius: isEarnedCenter ? 2 : 0,
                offset: const Offset(0, 5),
              ),
              if (isEarnedCenter)
                BoxShadow(
                  color: tier.color.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              const BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
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
                      size: isEarnedCenter ? 26 : 20,
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
                      child: Text(
                        tier.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.onAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: isEarnedCenter ? 18 : 15,
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
