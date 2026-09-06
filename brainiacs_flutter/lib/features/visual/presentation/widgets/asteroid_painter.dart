import 'dart:math';

import 'package:flutter/material.dart';

class AsteroidPainter extends CustomPainter {
  const AsteroidPainter({required this.id, required this.color});

  final int id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(id);
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide / 2;
    // Leave room so the outline stroke isn't clipped by the canvas.
    final radius = outerRadius * 0.92;
    final path = _buildRockPath(center, radius, rng);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    canvas.save();
    canvas.clipPath(path);
    _drawCraters(canvas, center, radius, rng);
    canvas.restore();

    final strokeWidth = (radius * 0.08).clamp(2.0, 4.5);
    final outerStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outerStroke);

    final innerStroke = Paint()
      ..color = Color.lerp(color, const Color(0xFF000000), 0.35)!
          .withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.45
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, innerStroke);
  }

  Path _buildRockPath(Offset center, double radius, Random rng) {
    final vertexCount = 7 + rng.nextInt(4);
    final points = <Offset>[];

    for (var i = 0; i < vertexCount; i++) {
      final theta = (i / vertexCount) * pi * 2;
      final jitter = 0.78 + rng.nextDouble() * 0.24;
      points.add(
        Offset(
          center.dx + cos(theta) * radius * jitter,
          center.dy + sin(theta) * radius * jitter,
        ),
      );
    }

    final path = Path();
    if (points.length < 3) {
      path.addOval(Rect.fromCircle(center: center, radius: radius));
      return path;
    }

    final firstMid = Offset(
      (points.last.dx + points.first.dx) / 2,
      (points.last.dy + points.first.dy) / 2,
    );
    path.moveTo(firstMid.dx, firstMid.dy);

    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.close();
    return path;
  }

  void _drawCraters(Canvas canvas, Offset center, double radius, Random rng) {
    final craterCount = 3 + rng.nextInt(4);
    final craterColor =
        Color.lerp(color, const Color(0xFF000000), 0.2) ??
        color.withValues(alpha: 0.85);
    final highlight = Color.lerp(color, const Color(0xFFFFFFFF), 0.16) ?? color;

    for (var i = 0; i < craterCount; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final distance = rng.nextDouble() * radius * 0.55;
      final craterRadius = radius * (0.08 + rng.nextDouble() * 0.16);
      final craterCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: craterCenter,
          width: craterRadius * 2,
          height: craterRadius * (1.4 + rng.nextDouble() * 0.4),
        ),
        Paint()..color = craterColor,
      );
      canvas.drawCircle(
        craterCenter.translate(-craterRadius * 0.18, -craterRadius * 0.18),
        craterRadius * 0.28,
        Paint()..color = highlight.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AsteroidPainter oldDelegate) {
    return oldDelegate.id != id || oldDelegate.color != color;
  }
}
