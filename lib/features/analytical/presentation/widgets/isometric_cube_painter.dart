import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/cube_puzzle.dart';
import 'cube_drop.dart';

class IsometricCubePainter extends CustomPainter {
  IsometricCubePainter({
    required this.puzzle,
    required this.progress,
  }) : super(repaint: progress);

  final CubePuzzle puzzle;
  final Animation<double> progress;

  static const List<Color> _baseColors = [
    AppColors.electricBlue,
    AppColors.coral,
    AppColors.vibrantPurple,
    AppColors.mint,
  ];

  static const double _fitPadding = 8;

  /// Fixed reference layout so cube size stays constant across questions.
  static const int _referenceGrid = 4;
  static const int _referenceMaxHeight = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = puzzle.rows;
    final cols = puzzle.cols;
    if (rows == 0 || cols == 0 || size.width <= 0 || size.height <= 0) {
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

    const unitTileW = 1.0;
    final unitTileH = unitTileW * CubePuzzle.isoTileAspect;
    final unitRise = unitTileH * CubePuzzle.isoRiseFactor;
    final unitHalfW = unitTileW * 0.5;
    final unitHalfH = unitTileH * 0.5;
    final unitExtentY = unitRise + unitHalfH;

    Offset unitCellCenter(int row, int col, int layer) {
      return Offset(
        (col - row) * unitTileW * 0.5,
        (col + row) * unitTileH * 0.5 - layer * unitRise,
      );
    }

    (double minX, double maxX, double minY, double maxY) boundsForGrid({
      required int gridRows,
      required int gridCols,
      required int heightLayers,
    }) {
      var minX = double.infinity;
      var maxX = -double.infinity;
      var minY = double.infinity;
      var maxY = -double.infinity;

      void include(Offset center, {required bool withTop}) {
        minX = math.min(minX, center.dx - unitHalfW);
        maxX = math.max(maxX, center.dx + unitHalfW);
        maxY = math.max(maxY, center.dy + unitHalfH);
        if (withTop) {
          minY = math.min(minY, center.dy - unitExtentY);
        } else {
          minY = math.min(minY, center.dy - unitHalfH);
        }
      }

      for (var r = 0; r < gridRows; r++) {
        for (var c = 0; c < gridCols; c++) {
          include(unitCellCenter(r, c, 0), withTop: false);
          include(unitCellCenter(r, c, heightLayers - 1), withTop: true);
        }
      }
      return (minX, maxX, minY, maxY);
    }

    final refBounds = boundsForGrid(
      gridRows: _referenceGrid,
      gridCols: _referenceGrid,
      heightLayers: _referenceMaxHeight,
    );
    final refW = (refBounds.$2 - refBounds.$1).clamp(0.001, double.infinity);
    final refH = (refBounds.$4 - refBounds.$3).clamp(0.001, double.infinity);
    final availableW = (size.width - _fitPadding * 2).clamp(1.0, size.width);
    final availableH = (size.height - _fitPadding * 2).clamp(1.0, size.height);
    final scale = math.min(availableW / refW, availableH / refH);

    final tileW = unitTileW * scale;
    final tileH = unitTileH * scale;
    final rise = unitRise * scale;

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
    if (cubes.isEmpty) {
      return;
    }

    // Paint order: back-to-front, then bottom-to-top.
    cubes.sort((a, b) {
      final depthA = a.row + a.col;
      final depthB = b.row + b.col;
      if (depthA != depthB) {
        return depthA.compareTo(depthB);
      }
      return a.layer.compareTo(b.layer);
    });

    // Within each layer, stagger back→front then left→right so drops cascade.
    final staggerIndexByCube = <_CubeInstance, int>{};
    final nextStagger = <int, int>{};
    final staggerOrder = List<_CubeInstance>.from(cubes)
      ..sort((a, b) {
        if (a.layer != b.layer) {
          return a.layer.compareTo(b.layer);
        }
        final depthA = a.row + a.col;
        final depthB = b.row + b.col;
        if (depthA != depthB) {
          return depthA.compareTo(depthB);
        }
        return (a.col - a.row).compareTo(b.col - b.row);
      });
    for (final cube in staggerOrder) {
      final index = nextStagger[cube.layer] ?? 0;
      staggerIndexByCube[cube] = index;
      nextStagger[cube.layer] = index + 1;
    }

    // Center the actual puzzle footprint (full grid cells, not only occupied).
    final puzzleBounds = boundsForGrid(
      gridRows: rows,
      gridCols: cols,
      heightLayers: maxHeight,
    );
    final puzzleW = (puzzleBounds.$2 - puzzleBounds.$1) * scale;
    final puzzleH = (puzzleBounds.$4 - puzzleBounds.$3) * scale;
    final originX =
        (size.width - puzzleW) * 0.5 - puzzleBounds.$1 * scale;
    final originY =
        (size.height - puzzleH) * 0.5 - puzzleBounds.$3 * scale;

    final fallDistance = rise * CubeDrop.fallDistanceRiseFactor;
    final t = progress.value.clamp(0.0, 1.0);
    final totalMs = CubeDrop.durationForPuzzle(puzzle).inMilliseconds;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (final cube in cubes) {
      final dropOffset = CubeDrop.offsetY(
        layer: cube.layer,
        staggerIndex: staggerIndexByCube[cube] ?? 0,
        t: t,
        totalMs: totalMs,
        fallDistance: fallDistance,
      );
      if (dropOffset == null) {
        continue;
      }
      final unit = unitCellCenter(cube.row, cube.col, cube.layer);
      final center = Offset(
        originX + unit.dx * scale,
        originY + unit.dy * scale + dropOffset,
      );
      _drawCube(canvas, center, tileW, tileH, rise, cube.color);
    }

    canvas.restore();
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
    return !identical(oldDelegate.puzzle, puzzle) ||
        oldDelegate.progress.value != progress.value;
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
