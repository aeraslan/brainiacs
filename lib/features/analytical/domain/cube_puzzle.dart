import 'dart:math';

class CubePuzzle {
  const CubePuzzle({
    required this.heights,
    required this.expectedTotal,
    required this.level,
  });

  final List<List<int>> heights;
  final int expectedTotal;
  final int level;

  int get rows => heights.length;

  int get cols => heights.isEmpty ? 0 : heights.first.length;

  int get requiredDigitCount => expectedTotal.toString().length;

  factory CubePuzzle.generate(
    int level, {
    Random? random,
    CubePuzzle? excluding,
  }) {
    final rng = random ?? Random();
    final safeLevel = level < 1 ? 1 : level;
    final size = _gridSizeForLevel(safeLevel);
    final maxHeight = _maxHeightForLevel(safeLevel);
    final minTotal = _minTotalForLevel(safeLevel);
    final maxTotal = _maxTotalForLevel(safeLevel);

    for (var attempt = 0; attempt < 160; attempt++) {
      final heights = List.generate(
        size,
        (_) => List.generate(size, (_) {
          if (rng.nextDouble() < _sparsityForLevel(safeLevel)) {
            return 0;
          }
          return rng.nextInt(maxHeight) + 1;
        }),
      );

      _removeOccludedColumns(heights);

      final total = _totalCubes(heights);
      if (total < minTotal || total > maxTotal) {
        continue;
      }
      if (!_allOccupiedColumnsVisible(heights)) {
        continue;
      }
      if (excluding != null && _sameLayout(heights, excluding.heights)) {
        continue;
      }

      return CubePuzzle(
        heights: heights,
        expectedTotal: total,
        level: safeLevel,
      );
    }

    return _fallbackPuzzle(safeLevel, excluding: excluding);
  }

  static bool _sameLayout(List<List<int>> a, List<List<int>> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var r = 0; r < a.length; r++) {
      if (a[r].length != b[r].length) {
        return false;
      }
      for (var c = 0; c < a[r].length; c++) {
        if (a[r][c] != b[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  /// Matches [IsometricCubePainter]: tile height / width and vertical rise.
  static const double isoTileAspect = 0.58;
  static const double isoRiseFactor = 0.95;

  /// A tall stack in front can hide a shorter one behind it, including on
  /// neighboring isometric diagonals (not only `col - row`). Clear those
  /// columns so every remaining stack has a top the player can actually see.
  static void _removeOccludedColumns(List<List<int>> heights) {
    final rows = heights.length;
    final cols = heights.first.length;
    final occupied = <(int, int)>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (heights[r][c] > 0) {
          occupied.add((r, c));
        }
      }
    }

    // Front of camera first: larger (row + col).
    occupied.sort((a, b) => (b.$1 + b.$2).compareTo(a.$1 + a.$2));

    final visible = <(int, int)>[];
    for (final (row, col) in occupied) {
      final height = heights[row][col];
      final hidden = visible.any((front) {
        return _frontHidesBack(
          backRow: row,
          backCol: col,
          backHeight: height,
          frontRow: front.$1,
          frontCol: front.$2,
          frontHeight: heights[front.$1][front.$2],
        );
      });
      if (hidden) {
        heights[row][col] = 0;
      } else {
        visible.add((row, col));
      }
    }
  }

  /// True when every occupied column's top sits above every in-front stack
  /// that overlaps it on screen.
  static bool _allOccupiedColumnsVisible(List<List<int>> heights) {
    final rows = heights.length;
    final cols = heights.first.length;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final height = heights[r][c];
        if (height <= 0) {
          continue;
        }

        for (var r2 = 0; r2 < rows; r2++) {
          for (var c2 = 0; c2 < cols; c2++) {
            if (_frontHidesBack(
              backRow: r,
              backCol: c,
              backHeight: height,
              frontRow: r2,
              frontCol: c2,
              frontHeight: heights[r2][c2],
            )) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  /// Uses the same projection as the painter: a back stack is hidden when its
  /// top is at or below the highest point of an overlapping front stack.
  static bool _frontHidesBack({
    required int backRow,
    required int backCol,
    required int backHeight,
    required int frontRow,
    required int frontCol,
    required int frontHeight,
  }) {
    if (frontHeight <= 0 || backHeight <= 0) {
      return false;
    }

    final depthDiff = (frontRow + frontCol) - (backRow + backCol);
    if (depthDiff <= 0) {
      return false;
    }

    final diagDiff = ((frontCol - frontRow) - (backCol - backRow)).abs();
    // Screen-X overlap: |Δdiag| * 0.5 * tileW < tileW ⇒ |Δdiag| < 2.
    // Include the touching case (|Δdiag| == 2) so edge-on towers cannot hide.
    if (diagDiff > 2) {
      return false;
    }

    final heightDelta = backHeight - frontHeight;
    final peekThreshold = (0.5 / isoRiseFactor) * (1 - depthDiff);
    return heightDelta <= peekThreshold;
  }

  static int _totalCubes(List<List<int>> heights) {
    return heights.fold<int>(
      0,
      (sum, row) => sum + row.fold<int>(0, (rowSum, h) => rowSum + h),
    );
  }

  static CubePuzzle _fallbackPuzzle(int level, {CubePuzzle? excluding}) {
    final candidates = <List<List<int>>>[
      [
        [2, 0],
        [0, 1],
      ],
      [
        [1, 1],
        [0, 1],
      ],
      [
        [1, 0],
        [1, 1],
      ],
      [
        [3, 0],
        [0, 1],
      ],
    ];

    for (final heights in candidates) {
      if (excluding == null || !_sameLayout(heights, excluding.heights)) {
        return CubePuzzle(
          heights: heights,
          expectedTotal: _totalCubes(heights),
          level: level,
        );
      }
    }

    final heights = candidates.first;
    return CubePuzzle(
      heights: heights,
      expectedTotal: _totalCubes(heights),
      level: level,
    );
  }

  /// Early levels stay small (≤8). Growth is slow; totals rarely exceed 20.
  static int _maxTotalForLevel(int level) {
    if (level <= 2) {
      return 5;
    }
    if (level <= 5) {
      return 8;
    }
    if (level <= 9) {
      return 11;
    }
    if (level <= 14) {
      return 14;
    }
    if (level <= 22) {
      return 17;
    }
    if (level <= 35) {
      return 20;
    }
    // Only very long / very fast runs go slightly over 20.
    if (level <= 50) {
      return 22;
    }
    return 24;
  }

  static int _minTotalForLevel(int level) {
    if (level <= 2) {
      return 1;
    }
    if (level <= 5) {
      return 3;
    }
    if (level <= 9) {
      return 5;
    }
    if (level <= 14) {
      return 7;
    }
    if (level <= 22) {
      return 9;
    }
    return 11;
  }

  static int _gridSizeForLevel(int level) {
    if (level <= 5) {
      return 2;
    }
    if (level <= 14) {
      return 3;
    }
    if (level <= 35) {
      return 4;
    }
    return 4;
  }

  static int _maxHeightForLevel(int level) {
    if (level <= 4) {
      return 2;
    }
    if (level <= 12) {
      return 3;
    }
    if (level <= 30) {
      return 4;
    }
    return 4;
  }

  static double _sparsityForLevel(int level) {
    if (level <= 5) {
      return 0.35;
    }
    if (level <= 14) {
      return 0.4;
    }
    return 0.45;
  }
}
