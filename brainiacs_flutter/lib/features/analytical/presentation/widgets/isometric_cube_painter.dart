import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/cube_puzzle.dart';

class IsometricCubePainter extends CustomPainter {
  IsometricCubePainter({required this.puzzle});

  final CubePuzzle puzzle;

  static const List<Color> _baseColors = [
    AppColors.electricBlue,
    AppColors.coral,
    AppColors.vibrantPurple,
    AppColors.mint,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rows = puzzle.rows;
    final cols = puzzle.cols;
    if (rows == 0 || cols == 0) {
      return;
    }

    var maxHeight = 0;
    for (final row in puzzle.heights) {
      for (final h in row) {
        if (h > maxHeight) {
          maxHeight = h;
        }
      }
    }
    if (maxHeight == 0) {
      return;
    }

    final tileW = size.width / (rows + cols);
    final tileH = tileW * CubePuzzle.isoTileAspect;
    final rise = tileH * CubePuzzle.isoRiseFactor;

    final gridDepth = (cols + rows) * tileH * 0.5;
    final gridHeight = maxHeight * rise;

    final originX = size.width * 0.5;
    final originY = (size.height - gridDepth - gridHeight) * 0.45 + gridHeight;

    final cubes = <_CubeInstance>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final height = puzzle.heights[r][c];
        if (height <= 0) {
          continue;
        }
        final base = _baseColors[(r * cols + c) % _baseColors.length];
        for (var z = 0; z < height; z++) {
          cubes.add(_CubeInstance(row: r, col: c, layer: z, color: base));
        }
      }
    }

    cubes.sort((a, b) {
      final depthA = a.row + a.col;
      final depthB = b.row + b.col;
      if (depthA != depthB) {
        return depthA.compareTo(depthB);
      }
      return a.layer.compareTo(b.layer);
    });

    for (final cube in cubes) {
      final center = Offset(
        originX + (cube.col - cube.row) * tileW * 0.5,
        originY + (cube.col + cube.row) * tileH * 0.5 - cube.layer * rise,
      );
      _drawCube(canvas, center, tileW, tileH, rise, cube.color);
    }
  }

  void _drawCube(
    Canvas canvas,
    Offset center,
    double tileW,
    double tileH,
    double rise,
    Color base,
  ) {
    final hw = tileW * 0.5;
    final hh = tileH * 0.5;

    final top = center.translate(0, -rise);
    final topN = top.translate(0, -hh);
    final topE = top.translate(hw, 0);
    final topS = top.translate(0, hh);
    final topW = top.translate(-hw, 0);

    final bottomE = center.translate(hw, 0);
    final bottomS = center.translate(0, hh);
    final bottomW = center.translate(-hw, 0);

    final topColor = Color.lerp(base, Colors.white, 0.35) ?? base;
    final leftColor = Color.lerp(base, Colors.black, 0.15) ?? base;
    final rightColor = Color.lerp(base, Colors.black, 0.35) ?? base;

    final stroke = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;

    void fillPoly(List<Offset> points, Color color) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, stroke);
    }

    fillPoly([topW, topS, bottomS, bottomW], leftColor);
    fillPoly([topE, topS, bottomS, bottomE], rightColor);
    fillPoly([topN, topE, topS, topW], topColor);

    final studScale = 0.28;
    final studHw = hw * studScale;
    final studHh = hh * studScale;
    final studRise = rise * 0.18;
    final studCenter = top;
    final studTop = studCenter.translate(0, -studRise);

    final sN = studTop.translate(0, -studHh);
    final sE = studTop.translate(studHw, 0);
    final sS = studTop.translate(0, studHh);
    final sW = studTop.translate(-studHw, 0);
    final sBottomE = studCenter.translate(studHw, 0);
    final sBottomS = studCenter.translate(0, studHh);
    final sBottomW = studCenter.translate(-studHw, 0);

    fillPoly([sW, sS, sBottomS, sBottomW], leftColor);
    fillPoly([sE, sS, sBottomS, sBottomE], rightColor);
    fillPoly([sN, sE, sS, sW], topColor);
  }

  @override
  bool shouldRepaint(covariant IsometricCubePainter oldDelegate) {
    return !identical(oldDelegate.puzzle, puzzle);
  }
}

class _CubeInstance {
  const _CubeInstance({
    required this.row,
    required this.col,
    required this.layer,
    required this.color,
  });

  final int row;
  final int col;
  final int layer;
  final Color color;
}
