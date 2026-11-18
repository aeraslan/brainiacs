import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/tutorial/tutorial_pointer.dart';

/// Rounded miniature demo frame with a "WATCH FIRST" badge.
///
/// User interaction is fully absorbed. Spotlight dim and virtual hand live
/// inside the clipped card so they stay aligned with the scaled demo.
class TutorialDemoCard extends StatelessWidget {
  const TutorialDemoCard({
    super.key,
    required this.overlayKey,
    required this.pointerController,
    required this.child,
    required this.accentColor,
  });

  final GlobalKey overlayKey;
  final TutorialPointerController pointerController;
  final Widget child;
  final Color accentColor;

  static const double _widthFactor = 0.72;
  static const double _referenceWidth = 390;
  static const double _referenceHeight = 640;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * _widthFactor;
        final maxHeight = constraints.maxHeight;
        final cardWidth = maxWidth.clamp(0.0, constraints.maxWidth);
        final aspect = _referenceWidth / _referenceHeight;
        var cardHeight = cardWidth / aspect;
        if (cardHeight > maxHeight) {
          cardHeight = maxHeight;
        }

        return Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  const BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.lg - 2),
                child: Stack(
                  key: overlayKey,
                  fit: StackFit.expand,
                  children: [
                    AbsorbPointer(
                      child: IgnorePointer(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: _referenceWidth,
                            height: _referenceHeight,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                padding: EdgeInsets.zero,
                                viewPadding: EdgeInsets.zero,
                                viewInsets: EdgeInsets.zero,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: AbsorbPointer(
                        child: ColoredBox(color: Colors.transparent),
                      ),
                    ),
                    Positioned.fill(
                      child: _TutorialDimOverlay(
                        controller: pointerController,
                      ),
                    ),
                    TutorialPointer(controller: pointerController),
                    Positioned(
                      top: AppSpacing.sm,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _WatchFirstBadge(accentColor: accentColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WatchFirstBadge extends StatelessWidget {
  const _WatchFirstBadge({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(color: accentColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 1,
        ),
        child: Text(
          'WATCH FIRST',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _TutorialDimOverlay extends StatelessWidget {
  const _TutorialDimOverlay({required this.controller});

  final TutorialPointerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Rect?>(
      valueListenable: controller.spotlightRect,
      builder: (context, hole, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _SpotlightDimPainter(hole: hole),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _SpotlightDimPainter extends CustomPainter {
  const _SpotlightDimPainter({required this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final dimPath = Path()..addRect(bounds);
    RRect? holeRRect;

    if (hole != null) {
      final clipped = hole!.intersect(bounds);
      if (!clipped.isEmpty) {
        holeRRect = RRect.fromRectAndRadius(
          clipped,
          const Radius.circular(AppSpacing.md),
        );
        dimPath
          ..addRRect(holeRRect)
          ..fillType = PathFillType.evenOdd;
      }
    }

    canvas.drawPath(dimPath, Paint()..color = Colors.black45);

    if (holeRRect != null) {
      final glowPaint = Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(holeRRect.inflate(2), glowPaint);

      final rimPaint = Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(holeRRect, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightDimPainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}
