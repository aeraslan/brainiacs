import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/session/game_session_state.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.timeRemaining,
    this.maxTime = GameSessionState.maxTimeLimit,
    this.size = 72,
  });

  final int timeRemaining;
  final int maxTime;
  final double size;

  @override
  Widget build(BuildContext context) {
    final elapsedFraction =
        ((maxTime - timeRemaining) / maxTime).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularTimerPainter(elapsedFraction: elapsedFraction),
        child: Center(
          child: Text(
            '$timeRemaining',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ),
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  const _CircularTimerPainter({required this.elapsedFraction});

  final double elapsedFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * elapsedFraction;

    final borderPaint = Paint()
      ..color = AppColors.timerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final remainingPaint = Paint()
      ..color = AppColors.timerRemaining
      ..style = PaintingStyle.fill;

    final elapsedPaint = Paint()
      ..color = AppColors.timerElapsed
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 2, remainingPaint);

    if (elapsedFraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        true,
        elapsedPaint,
      );
    }

    canvas.drawCircle(center, radius - 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.elapsedFraction != elapsedFraction;
  }
}
