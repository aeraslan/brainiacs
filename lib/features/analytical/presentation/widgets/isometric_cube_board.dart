import 'package:flutter/material.dart';

import '../../domain/cube_puzzle.dart';
import 'cube_drop.dart';
import 'isometric_cube_painter.dart';

class IsometricCubeBoard extends StatefulWidget {
  const IsometricCubeBoard({
    super.key,
    required this.puzzle,
    this.onDropComplete,
  });

  final CubePuzzle puzzle;
  final VoidCallback? onDropComplete;

  @override
  State<IsometricCubeBoard> createState() => _IsometricCubeBoardState();
}

class _IsometricCubeBoardState extends State<IsometricCubeBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_onStatus);
    _restartDrop();
  }

  @override
  void didUpdateWidget(IsometricCubeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.puzzle, widget.puzzle)) {
      _restartDrop();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onDropComplete?.call();
    }
  }

  void _restartDrop() {
    final duration = CubeDrop.durationForPuzzle(widget.puzzle);
    _controller.duration = duration;
    if (duration == Duration.zero) {
      _controller.value = 1;
      // Fire after the current frame so the screen can enable input.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onDropComplete?.call();
        }
      });
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: IsometricCubePainter(
            puzzle: widget.puzzle,
            progress: _controller,
          ),
        );
      },
    );
  }
}
