import 'dart:math';

import 'package:flutter/material.dart';

/// Lightweight asteroid silhouette for menu décor (menu-local, not game logic).
class DecorAsteroid extends StatelessWidget {
  const DecorAsteroid({
    super.key,
    required this.color,
    this.id = 0,
    this.size = 40,
  });

  final Color color;
  final int id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DecorAsteroidPainter(id: id, color: color),
      ),
    );
  }
}

class DecorAsteroidPainter extends CustomPainter {
  const DecorAsteroidPainter({required this.id, required this.color});

  final int id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(id);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.42;
    final path = _rockPath(center, radius, rng);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    canvas.save();
    canvas.clipPath(path);
    for (var i = 0; i < 3; i++) {
      final craterCenter = Offset(
        center.dx + (rng.nextDouble() - 0.5) * radius * 0.9,
        center.dy + (rng.nextDouble() - 0.5) * radius * 0.9,
      );
      final craterR = radius * (0.12 + rng.nextDouble() * 0.14);
      canvas.drawCircle(
        craterCenter,
        craterR,
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );
    }
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (radius * 0.08).clamp(1.5, 3.0)
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _rockPath(Offset center, double radius, Random rng) {
    final vertexCount = 7 + rng.nextInt(3);
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
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldRepaint(covariant DecorAsteroidPainter oldDelegate) {
    return oldDelegate.id != id || oldDelegate.color != color;
  }
}
