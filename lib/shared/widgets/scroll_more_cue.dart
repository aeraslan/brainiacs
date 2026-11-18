import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Subtle bottom-of-viewport cue that more content exists below.
///
/// Non-interactive; typically hosted by [ScrollOverflowHint].
class ScrollMoreCue extends StatelessWidget {
  const ScrollMoreCue({super.key});

  static const String label = 'Scroll for more';

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget chevron = const Icon(
      Icons.keyboard_arrow_down_rounded,
      size: 20,
      color: AppColors.textSecondary,
    );

    if (!reduceMotion) {
      chevron = chevron
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: 3,
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: SizedBox(
            height: 28,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0),
                    AppColors.background.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),
        ),
        ColoredBox(
          color: AppColors.background.withValues(alpha: 0.72),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(width: AppSpacing.xs),
                chevron,
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: reduceMotion ? 0.ms : 220.ms);
  }
}

/// Scroll viewport that shows [ScrollMoreCue] when content overflows.
///
/// The cue hides after the first downward scroll and does not return for
/// the lifetime of this widget.
class ScrollOverflowHint extends StatefulWidget {
  const ScrollOverflowHint({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.centerContentVertically = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  /// When true, content is given a min height of the viewport (minus padding)
  /// so short content can be vertically centered by its own layout.
  final bool centerContentVertically;

  @override
  State<ScrollOverflowHint> createState() => _ScrollOverflowHintState();
}

class _ScrollOverflowHintState extends State<ScrollOverflowHint> {
  static const double _overflowEpsilon = 1;

  final ScrollController _scrollController = ScrollController();

  bool _hasOverflow = false;
  bool _hintDismissed = false;

  bool get _showHint => _hasOverflow && !_hintDismissed;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollPositionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverflow());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollPositionChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollPositionChanged() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (!_hintDismissed && _scrollController.position.pixels > 0) {
      setState(() => _hintDismissed = true);
      return;
    }
    _syncOverflow();
  }

  void _syncOverflow() {
    if (!mounted || !_scrollController.hasClients || _hintDismissed) {
      return;
    }
    final overflows =
        _scrollController.position.maxScrollExtent > _overflowEpsilon;
    if (overflows != _hasOverflow) {
      setState(() => _hasOverflow = overflows);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (!_hintDismissed && delta > 0) {
        setState(() => _hintDismissed = true);
      }
    }
    return false;
  }

  bool _onMetricsNotification(ScrollMetricsNotification notification) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverflow());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding = widget.padding.resolve(Directionality.of(context));
        final minHeight = widget.centerContentVertically
            ? constraints.maxHeight -
                resolvedPadding.top -
                resolvedPadding.bottom
            : null;

        Widget scrollChild = widget.child;
        if (minHeight != null) {
          scrollChild = ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: widget.child,
          );
        }

        return NotificationListener<ScrollMetricsNotification>(
          onNotification: _onMetricsNotification,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: widget.physics,
                  padding: widget.padding,
                  child: scrollChild,
                ),
                if (_showHint)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: ScrollMoreCue(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
