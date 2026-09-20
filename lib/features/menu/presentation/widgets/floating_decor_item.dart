import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Positions a décor child and runs an infinite float + rotate loop.
class FloatingDecorItem extends StatelessWidget {
  const FloatingDecorItem({
    super.key,
    required this.alignment,
    required this.child,
    this.delay = Duration.zero,
    this.floatDuration = const Duration(milliseconds: 4200),
    this.rotateDuration = const Duration(milliseconds: 11000),
    this.floatOffset = 14,
    this.rotateTurns = 0.08,
    this.opacityBegin = 0.2,
    this.opacityEnd = 0.32,
  });

  final Alignment alignment;
  final Widget child;
  final Duration delay;
  final Duration floatDuration;
  final Duration rotateDuration;
  final double floatOffset;
  final double rotateTurns;
  final double opacityBegin;
  final double opacityEnd;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: RepaintBoundary(
        child: child
            .animate(
              delay: delay,
              onPlay: (controller) => controller.loop(reverse: true),
            )
            .fade(
              begin: opacityBegin,
              end: opacityEnd,
              duration: floatDuration,
              curve: Curves.easeInOut,
            )
            .moveY(
              begin: -floatOffset,
              end: floatOffset,
              duration: floatDuration,
              curve: Curves.easeInOut,
            )
            .rotate(
              begin: -rotateTurns,
              end: rotateTurns,
              duration: rotateDuration,
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}
