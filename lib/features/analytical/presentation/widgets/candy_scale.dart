import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/balance_puzzle.dart';
import 'balance_object_image.dart';

/// Polished slate charcoal — uniform across all Balance Logic scales.
const Color kBalanceScaleSlate = Color(0xFF5C6670);

/// Thick glossy candy balance scale with object image weights seated on level pans.
class CandyScale extends StatelessWidget {
  const CandyScale({
    super.key,
    required this.comparison,
    this.accentColor = kBalanceScaleSlate,
    this.objectSize = 48,
    this.scaleWidth = 200,
  });

  final BalanceScaleComparison comparison;
  final Color accentColor;
  final double objectSize;
  final double scaleWidth;

  static const double tiltTurns = 0.05;
  static const double wobbleTurns = 0.008;

  Color get _darkAccent {
    final hsl = HSLColor.fromColor(accentColor);
    return hsl.withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0)).toColor();
  }

  static double _sizeFactor(int count) {
    if (count <= 1) {
      return 1;
    }
    if (count == 2) {
      return 0.72;
    }
    return 0.55;
  }

  static double _panWidthFor(double basePanWidth, int itemCount, double itemSize) {
    if (itemCount <= 1) {
      return basePanWidth;
    }
    final overlap = itemSize * 0.22;
    final rowWidth = itemCount * itemSize - (itemCount - 1) * overlap;
    return rowWidth.clamp(basePanWidth, basePanWidth * 1.85);
  }

  @override
  Widget build(BuildContext context) {
    final maxItems = [
      comparison.leftItems.length,
      comparison.rightItems.length,
    ].reduce((a, b) => a > b ? a : b);
    final itemSize = objectSize * _sizeFactor(maxItems);
    final basePanWidth = scaleWidth * 0.36;
    final leftPanWidth = _panWidthFor(
      basePanWidth,
      comparison.leftItems.length,
      itemSize,
    );
    final rightPanWidth = _panWidthFor(
      basePanWidth,
      comparison.rightItems.length,
      itemSize,
    );
    final panHeight = basePanWidth * 0.28;
    final beamHeight = scaleWidth * 0.075;
    final fulcrumWidth = scaleWidth * 0.22;
    final fulcrumHeight = fulcrumWidth * 0.55;
    final baseWidth = scaleWidth * 0.28;
    final baseHeight = baseWidth * 0.28;

    final panStackHeight = itemSize + panHeight * 0.45;
    final armHeight = panStackHeight + beamHeight * 0.5;
    final tiltMargin = scaleWidth * 0.12;
    final totalHeight =
        armHeight + fulcrumHeight + baseHeight + tiltMargin + AppSpacing.sm;

    final tilt = comparison.isBalanced
        ? 0.0
        : comparison.tiltSign * tiltTurns;

    return SizedBox(
      width: scaleWidth + tiltMargin,
      height: totalHeight,
      child: _HangingScaleBody(
        comparison: comparison,
        accentColor: accentColor,
        darkAccent: _darkAccent,
        itemSize: itemSize,
        scaleWidth: scaleWidth,
        leftPanWidth: leftPanWidth,
        rightPanWidth: rightPanWidth,
        panHeight: panHeight,
        panStackHeight: panStackHeight,
        beamHeight: beamHeight,
        armHeight: armHeight,
        fulcrumWidth: fulcrumWidth,
        fulcrumHeight: fulcrumHeight,
        baseWidth: baseWidth,
        baseHeight: baseHeight,
        tiltTurns: tilt,
        animateDrop: !comparison.isBalanced,
        animateWobble: comparison.isBalanced,
      ),
    );
  }
}

class _HangingScaleBody extends StatelessWidget {
  const _HangingScaleBody({
    required this.comparison,
    required this.accentColor,
    required this.darkAccent,
    required this.itemSize,
    required this.scaleWidth,
    required this.leftPanWidth,
    required this.rightPanWidth,
    required this.panHeight,
    required this.panStackHeight,
    required this.beamHeight,
    required this.armHeight,
    required this.fulcrumWidth,
    required this.fulcrumHeight,
    required this.baseWidth,
    required this.baseHeight,
    required this.tiltTurns,
    required this.animateDrop,
    required this.animateWobble,
  });

  final BalanceScaleComparison comparison;
  final Color accentColor;
  final Color darkAccent;
  final double itemSize;
  final double scaleWidth;
  final double leftPanWidth;
  final double rightPanWidth;
  final double panHeight;
  final double panStackHeight;
  final double beamHeight;
  final double armHeight;
  final double fulcrumWidth;
  final double fulcrumHeight;
  final double baseWidth;
  final double baseHeight;
  final double tiltTurns;
  final bool animateDrop;
  final bool animateWobble;

  @override
  Widget build(BuildContext context) {
    final arm = _ScaleArm(
      comparison: comparison,
      accentColor: accentColor,
      darkAccent: darkAccent,
      itemSize: itemSize,
      scaleWidth: scaleWidth,
      leftPanWidth: leftPanWidth,
      rightPanWidth: rightPanWidth,
      panHeight: panHeight,
      panStackHeight: panStackHeight,
      beamHeight: beamHeight,
      armHeight: armHeight,
      tiltTurns: tiltTurns,
      animateDrop: animateDrop,
      animateWobble: animateWobble,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        arm,
        Transform.translate(
          offset: Offset(0, -beamHeight * 0.25),
          child: _FulcrumAndBase(
            fulcrumWidth: fulcrumWidth,
            fulcrumHeight: fulcrumHeight,
            baseWidth: baseWidth,
            baseHeight: baseHeight,
            accentColor: accentColor,
            darkAccent: darkAccent,
          ),
        ),
      ],
    );
  }
}

class _ScaleArm extends StatelessWidget {
  const _ScaleArm({
    required this.comparison,
    required this.accentColor,
    required this.darkAccent,
    required this.itemSize,
    required this.scaleWidth,
    required this.leftPanWidth,
    required this.rightPanWidth,
    required this.panHeight,
    required this.panStackHeight,
    required this.beamHeight,
    required this.armHeight,
    required this.tiltTurns,
    required this.animateDrop,
    required this.animateWobble,
  });

  final BalanceScaleComparison comparison;
  final Color accentColor;
  final Color darkAccent;
  final double itemSize;
  final double scaleWidth;
  final double leftPanWidth;
  final double rightPanWidth;
  final double panHeight;
  final double panStackHeight;
  final double beamHeight;
  final double armHeight;
  final double tiltTurns;
  final bool animateDrop;
  final bool animateWobble;

  @override
  Widget build(BuildContext context) {
    Widget arm = SizedBox(
      width: scaleWidth,
      height: armHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: scaleWidth * 0.04,
            right: scaleWidth * 0.04,
            bottom: 0,
            child: Container(
              height: beamHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(beamHeight),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.55),
                    accentColor,
                    darkAccent,
                  ],
                  stops: const [0.0, 0.22, 1.0],
                ),
                border: Border.all(color: darkAccent, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: beamHeight * 0.35,
            child: _LevelPanAssembly(
              items: comparison.leftItems,
              itemSize: itemSize,
              panWidth: leftPanWidth,
              panHeight: panHeight,
              panStackHeight: panStackHeight,
              accentColor: accentColor,
              darkAccent: darkAccent,
              counterRotateTurns: -tiltTurns,
              animateDrop: animateDrop,
              animateWobble: animateWobble,
            ),
          ),
          Positioned(
            right: 0,
            bottom: beamHeight * 0.35,
            child: _LevelPanAssembly(
              items: comparison.rightItems,
              itemSize: itemSize,
              panWidth: rightPanWidth,
              panHeight: panHeight,
              panStackHeight: panStackHeight,
              accentColor: accentColor,
              darkAccent: darkAccent,
              counterRotateTurns: -tiltTurns,
              animateDrop: animateDrop,
              animateWobble: animateWobble,
            ),
          ),
        ],
      ),
    );

    if (animateDrop) {
      arm = arm
          .animate()
          .rotate(
            begin: 0,
            end: tiltTurns,
            delay: 300.ms,
            duration: 800.ms,
            curve: Curves.bounceOut,
            alignment: Alignment.bottomCenter,
          );
    } else if (animateWobble) {
      arm = arm
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .rotate(
            begin: -CandyScale.wobbleTurns,
            end: CandyScale.wobbleTurns,
            duration: 1400.ms,
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
          );
    }

    return arm;
  }
}

/// Pan + object row that stays level to the ground via inverse rotation.
class _LevelPanAssembly extends StatelessWidget {
  const _LevelPanAssembly({
    required this.items,
    required this.itemSize,
    required this.panWidth,
    required this.panHeight,
    required this.panStackHeight,
    required this.accentColor,
    required this.darkAccent,
    required this.counterRotateTurns,
    required this.animateDrop,
    required this.animateWobble,
  });

  final List<String> items;
  final double itemSize;
  final double panWidth;
  final double panHeight;
  final double panStackHeight;
  final Color accentColor;
  final Color darkAccent;
  final double counterRotateTurns;
  final bool animateDrop;
  final bool animateWobble;

  @override
  Widget build(BuildContext context) {
    final overlap = itemSize * 0.22;
    final itemCount = items.length;
    final rowWidth = itemCount <= 1
        ? itemSize
        : itemCount * itemSize - (itemCount - 1) * overlap;

    Widget assembly = SizedBox(
      width: panWidth,
      height: panStackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: panHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.7),
                    accentColor.withValues(alpha: 0.85),
                    darkAccent,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
                border: Border.all(color: darkAccent, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: panHeight * 0.55,
            child: Center(
              child: SizedBox(
                width: rowWidth,
                height: itemSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < itemCount; i++)
                      Positioned(
                        left: i * (itemSize - overlap),
                        top: 0,
                        child: BalanceObjectImage(
                          assetPath: items[i],
                          size: itemSize,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (animateDrop && counterRotateTurns != 0) {
      assembly = assembly
          .animate()
          .rotate(
            begin: 0,
            end: counterRotateTurns,
            delay: 300.ms,
            duration: 800.ms,
            curve: Curves.bounceOut,
            alignment: Alignment.bottomCenter,
          );
    } else if (animateWobble) {
      assembly = assembly
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .rotate(
            begin: CandyScale.wobbleTurns,
            end: -CandyScale.wobbleTurns,
            duration: 1400.ms,
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
          );
    }

    return assembly;
  }
}

class _FulcrumAndBase extends StatelessWidget {
  const _FulcrumAndBase({
    required this.fulcrumWidth,
    required this.fulcrumHeight,
    required this.baseWidth,
    required this.baseHeight,
    required this.accentColor,
    required this.darkAccent,
  });

  final double fulcrumWidth;
  final double fulcrumHeight;
  final double baseWidth;
  final double baseHeight;
  final Color accentColor;
  final Color darkAccent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(fulcrumWidth, fulcrumHeight),
          painter: _TrianglePainter(
            fill: accentColor,
            border: darkAccent,
            gloss: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Container(
            width: baseWidth,
            height: baseHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.45),
                  darkAccent,
                ],
              ),
              border: Border.all(color: darkAccent, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({
    required this.fill,
    required this.border,
    required this.gloss,
  });

  final Color fill;
  final Color border;
  final Color gloss;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gloss, fill, border],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.border != border ||
        oldDelegate.gloss != gloss;
  }
}
