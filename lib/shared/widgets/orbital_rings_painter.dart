import 'dart:math' as math;

import 'package:flutter/material.dart';

class OrbitalRingsPainter extends CustomPainter {
  const OrbitalRingsPainter({
    required this.ringColor,
    this.phase = 0,
  });

  final Color ringColor;

  /// Continuous loop progress in `[0, 1)`. Drives per-layer parallax.
  final double phase;

  static const List<double> _layerSpeeds = [0.55, 1.0, 1.35];
  static const double _expandAmplitude = 0.03;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(size.shortestSide * 0.16, 28.0);
    final paint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    _drawRing(
      canvas: canvas,
      paint: paint,
      center: Offset(size.width * 0.2, size.height * 0.42),
      width: size.width * 1.85,
      height: size.height * 0.72,
      rotation: -0.42,
      start: -0.15,
      sweep: 2.9,
      layerSpeed: _layerSpeeds[0],
    );
    _drawRing(
      canvas: canvas,
      paint: paint,
      center: Offset(size.width * 0.55, size.height * 0.58),
      width: size.width * 1.55,
      height: size.height * 0.58,
      rotation: -0.28,
      start: 0.2,
      sweep: 2.4,
      layerSpeed: _layerSpeeds[1],
    );
    _drawRing(
      canvas: canvas,
      paint: paint,
      center: Offset(size.width * 0.75, size.height * 0.22),
      width: size.width * 1.2,
      height: size.height * 0.45,
      rotation: 0.18,
      start: 0.6,
      sweep: 2.0,
      layerSpeed: _layerSpeeds[2],
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Paint paint,
    required Offset center,
    required double width,
    required double height,
    required double rotation,
    required double start,
    required double sweep,
    required double layerSpeed,
  }) {
    final layerPhase = phase * layerSpeed * math.pi * 2;
    final expand =
        1 + _expandAmplitude * math.sin(phase * layerSpeed * math.pi * 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation + layerPhase * 0.08);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset.zero,
        width: width * expand,
        height: height * expand,
      ),
      start + layerPhase,
      sweep,
      false,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OrbitalRingsPainter oldDelegate) {
    return oldDelegate.ringColor != ringColor || oldDelegate.phase != phase;
  }
}
