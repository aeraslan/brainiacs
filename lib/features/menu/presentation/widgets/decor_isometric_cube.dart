import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Lightweight single isometric cube for menu décor (not game logic).
class DecorIsometricCube extends StatelessWidget {
  const DecorIsometricCube({
    super.key,
    required this.color,
    this.size = 40,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DecorCubePainter(color: color),
      ),
    );
  }
}

class DecorCubePainter extends CustomPainter {
  const DecorCubePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final tileW = size.width * 0.72;
    final tileH = tileW * 0.58;
    final rise = tileH * 0.72;
    final hw = tileW * 0.5;
    final hh = tileH * 0.5;

    final center = Offset(size.width * 0.5, size.height * 0.62);

    final top = center.translate(0, -rise);
    final topN = top.translate(0, -hh);
    final topE = top.translate(hw, 0);
    final topS = top.translate(0, hh);
    final topW = top.translate(-hw, 0);

    final bottomE = center.translate(hw, 0);
    final bottomS = center.translate(0, hh);
    final bottomW = center.translate(-hw, 0);

    final topColor = Color.lerp(color, Colors.white, 0.4) ?? color;
    final leftColor = Color.lerp(color, Colors.black, 0.12) ?? color;
    final rightColor = Color.lerp(color, Colors.black, 0.28) ?? color;

    final stroke = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round;

    void fillPoly(List<Offset> points, Color fill) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, Paint()..color = fill);
      canvas.drawPath(path, stroke);
    }

    fillPoly([topW, topS, bottomS, bottomW], leftColor);
    fillPoly([topE, topS, bottomS, bottomE], rightColor);
    fillPoly([topN, topE, topS, topW], topColor);
  }

  @override
  bool shouldRepaint(covariant DecorCubePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
