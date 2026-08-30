import 'package:flutter/material.dart';

import '../../domain/cube_puzzle.dart';
import 'isometric_cube_painter.dart';

class IsometricCubeBoard extends StatelessWidget {
  const IsometricCubeBoard({
    super.key,
    required this.puzzle,
  });

  final CubePuzzle puzzle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: IsometricCubePainter(puzzle: puzzle),
        );
      },
    );
  }
}
