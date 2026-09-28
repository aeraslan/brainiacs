import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

class TutorialPointerController {
  TutorialPointerController({required this.overlayKey});

  final GlobalKey overlayKey;
  final ValueNotifier<Offset> position = ValueNotifier(
    const Offset(-160, -160),
  );
  final ValueNotifier<bool> isPressing = ValueNotifier(false);

  /// Spotlight hole in [overlayKey] local coordinates. Null = fully dimmed.
  final ValueNotifier<Rect?> spotlightRect = ValueNotifier(null);

  static const Duration moveDuration = Duration(milliseconds: 420);
  static const Duration pressDuration = Duration(milliseconds: 140);
  static const double spotlightPadding = 10;

  Offset? centerOf(GlobalKey key) {
    final target = key.currentContext?.findRenderObject();
    final overlay = overlayKey.currentContext?.findRenderObject();
    if (target is! RenderBox || overlay is! RenderBox || !target.hasSize) {
      return null;
    }

    final global = target.localToGlobal(target.size.center(Offset.zero));
    return overlay.globalToLocal(global);
  }

  Rect? rectOf(GlobalKey key) {
    final target = key.currentContext?.findRenderObject();
    final overlay = overlayKey.currentContext?.findRenderObject();
    if (target is! RenderBox || overlay is! RenderBox || !target.hasSize) {
      return null;
    }

    final topLeft = overlay.globalToLocal(target.localToGlobal(Offset.zero));
    final bottomRight = overlay.globalToLocal(
      target.localToGlobal(target.size.bottomRight(Offset.zero)),
    );
    return Rect.fromPoints(topLeft, bottomRight).inflate(spotlightPadding);
  }

  Future<bool> tapKey(GlobalKey key) async {
    final moved = await moveToKey(key);
    if (!moved) {
      return false;
    }

    isPressing.value = true;
    await Future<void>.delayed(pressDuration);
    isPressing.value = false;
    return true;
  }

  /// Moves the pointer to [key] without pressing (e.g. rest spot off the board).
  Future<bool> moveToKey(GlobalKey key) async {
    final target = centerOf(key);
    if (target == null) {
      return false;
    }

    spotlightRect.value = rectOf(key);
    position.value = target;
    await Future<void>.delayed(moveDuration);
    final settled = centerOf(key);
    if (settled != null) {
      position.value = settled;
    }
    final settledRect = rectOf(key);
    if (settledRect != null) {
      spotlightRect.value = settledRect;
    }
    return true;
  }

  void hide() {
    isPressing.value = false;
    position.value = const Offset(-160, -160);
    spotlightRect.value = null;
  }

  void dispose() {
    position.dispose();
    isPressing.dispose();
    spotlightRect.dispose();
  }
}

class TutorialPointer extends StatelessWidget {
  const TutorialPointer({super.key, required this.controller});

  final TutorialPointerController controller;

  static const double _iconSize = 56;
  static const Offset _hotspot = Offset(14, 6);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: controller.position,
      builder: (context, offset, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isPressing,
          builder: (context, isPressing, _) {
            return Positioned(
              left: offset.dx - _hotspot.dx,
              top: offset.dy - _hotspot.dy,
              child: IgnorePointer(
                child:
                    SizedBox(
                          width: _iconSize,
                          height: _iconSize,
                          child: const CustomPaint(
                            painter: _CandyGlovePainter(),
                          ),
                        )
                        .animate(target: isPressing ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(0.82, 0.82),
                          duration: 120.ms,
                        ),
              ),
            );
          },
        );
      },
    );
  }
}

/// White cartoon glove cursor with a glossy tip and coral cuff.
class _CandyGlovePainter extends CustomPainter {
  const _CandyGlovePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 56;
    canvas.scale(scale);

    // Soft drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    _drawGlove(canvas, const Offset(2, 3), shadowPaint);

    // Glove body
    final glovePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF0F2F8), Color(0xFFE2E6F0)],
      ).createShader(const Rect.fromLTWH(0, 0, 56, 56));
    _drawGlove(canvas, Offset.zero, glovePaint);

    // Gloss highlight on index finger tip
    final glossPaint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(14, 8), width: 8, height: 10),
      glossPaint,
    );

    // Coral candy cuff
    final cuffRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, 38, 22, 12),
      const Radius.circular(6),
    );
    final cuffPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8E8E), AppColors.coral, Color(0xFFE84E4E)],
      ).createShader(cuffRect.outerRect);
    canvas.drawRRect(cuffRect, cuffPaint);

    final cuffHighlight = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(cuffRect.deflate(1.5), cuffHighlight);

    // Outline
    final outlinePaint = Paint()
      ..color = const Color(0x332B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;
    _drawGlove(canvas, Offset.zero, outlinePaint);
  }

  void _drawGlove(Canvas canvas, Offset offset, Paint paint) {
    final path = Path();
    // Index finger (pointing up-left toward hotspot)
    path.moveTo(offset.dx + 18, offset.dy + 28);
    path.cubicTo(
      offset.dx + 16,
      offset.dy + 18,
      offset.dx + 12,
      offset.dy + 8,
      offset.dx + 14,
      offset.dy + 4,
    );
    path.cubicTo(
      offset.dx + 16,
      offset.dy + 1,
      offset.dx + 20,
      offset.dy + 2,
      offset.dx + 21,
      offset.dy + 8,
    );
    path.lineTo(offset.dx + 24, offset.dy + 22);

    // Middle finger knuckle bump
    path.cubicTo(
      offset.dx + 28,
      offset.dy + 18,
      offset.dx + 32,
      offset.dy + 18,
      offset.dx + 34,
      offset.dy + 24,
    );

    // Palm + cuff area
    path.cubicTo(
      offset.dx + 40,
      offset.dy + 28,
      offset.dx + 42,
      offset.dy + 36,
      offset.dx + 40,
      offset.dy + 44,
    );
    path.lineTo(offset.dx + 24, offset.dy + 46);
    path.cubicTo(
      offset.dx + 18,
      offset.dy + 42,
      offset.dx + 16,
      offset.dy + 34,
      offset.dx + 18,
      offset.dy + 28,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CandyGlovePainter oldDelegate) => false;
}

Future<bool> waitUntil(
  bool Function() test, {
  required bool Function() isActive,
  Duration timeout = const Duration(seconds: 4),
  Duration interval = const Duration(milliseconds: 50),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (isActive()) {
    if (test()) {
      return true;
    }
    if (DateTime.now().isAfter(deadline)) {
      return false;
    }
    await Future<void>.delayed(interval);
  }
  return false;
}

String wrongDigitString(int correctAnswer, int digitCount) {
  final modulus = _pow10(digitCount);
  var wrong = (correctAnswer + 1) % modulus;
  if (wrong == correctAnswer) {
    wrong = (correctAnswer + 2) % modulus;
  }
  return wrong.toString().padLeft(digitCount, '0');
}

int _pow10(int exponent) {
  var value = 1;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}
