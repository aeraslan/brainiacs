import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_spacing.dart';
import 'candy_memory_tile.dart';

class MatrixRecallBoard extends StatelessWidget {
  const MatrixRecallBoard({
    super.key,
    required this.gridSize,
    required this.litTileIndex,
    required this.wrongTileIndex,
    required this.inputUnlocked,
    required this.shakeToken,
    required this.onTileTapped,
    this.tileKeys,
  });

  final int gridSize;
  final int? litTileIndex;
  final int? wrongTileIndex;
  final bool inputUnlocked;
  final int shakeToken;
  final ValueChanged<int> onTileTapped;
  final List<GlobalKey>? tileKeys;

  /// Matches [CandyMemoryTile] lit/wrong scale so layout reserves room.
  static const double popScale = 1.1;

  int get _tileCount => gridSize * gridSize;

  GlobalKey? _keyForTile(int index) {
    final keys = tileKeys;
    if (keys == null || index < 0 || index >= keys.length) {
      return null;
    }
    return keys[index];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppSpacing.md;
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        // Shrink the grid so a 1.1 scale pop stays inside the available area.
        final boardSide = (maxSide / popScale).clamp(140.0, 400.0);
        final cellInset = spacing * 0.35;

        Widget grid = SizedBox(
          width: boardSide,
          height: boardSide,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: _tileCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(cellInset),
                child: CandyMemoryTile(
                  key: _keyForTile(index),
                  index: index,
                  isLit: litTileIndex == index,
                  isWrong: wrongTileIndex == index,
                  enabled: inputUnlocked,
                  onTap: () => onTileTapped(index),
                ),
              );
            },
          ),
        );

        if (shakeToken > 0) {
          grid = grid
              .animate(key: ValueKey('matrix-shake-$shakeToken'))
              .shakeX(amount: 8, duration: 250.ms, hz: 6);
        }

        return Center(child: grid);
      },
    );
  }
}
