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

    for (var attempt = 0; attempt < 320; attempt++) {
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

  /// True when every occupied column's top clears every overlapping front stack.
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
  /// top does not clearly clear an overlapping front stack.
  ///
  /// Edge-touching towers (`|diagDiff| >= 2`) do not cover each other. Real
  /// overlap requires the back stack to be tall enough that its top face peeks
  /// by more than a one-cube sliver for the depth gap.
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
    // Edge-touching (|Δdiag| == 2) is kept — footprints meet but do not cover.
    if (diagDiff >= 2) {
      return false;
    }

    final heightDelta = backHeight - frontHeight;
    // Depth 1 → need at least +1; depth 2 → need at least +2.
    final peekThreshold = (0.5 / isoRiseFactor) * depthDiff;
    return heightDelta <= peekThreshold;
  }

  /// Public visibility check for tests: every occupied stack top clears
  /// overlapping front stacks so the total is uniquely countable.
  static bool isUnambiguouslyVisible(List<List<int>> heights) {
    return _allOccupiedColumnsVisible(heights);
  }

  static int _totalCubes(List<List<int>> heights) {
    return heights.fold<int>(
      0,
      (sum, row) => sum + row.fold<int>(0, (rowSum, h) => rowSum + h),
    );
  }

  static CubePuzzle _fallbackPuzzle(int level, {CubePuzzle? excluding}) {
    final minTotal = _minTotalForLevel(level);
    final maxTotal = _maxTotalForLevel(level);
    // Unambiguous layouts: same-depth neighbors, edge-adjacent towers, and
    // taller stacks behind shorter ones that clearly clear the front top.
    final candidates = <List<List<int>>>[
      // Totals 2–3: only valid for the first two questions.
      [
        [2, 0],
        [0, 0],
      ],
      [
        [3, 0],
        [0, 0],
      ],
      [
        [0, 1],
        [1, 0],
      ],
      [
        [0, 2],
        [1, 0],
      ],
      // Totals 4+: same-depth pairs.
      [
        [0, 2],
        [2, 0],
      ],
      [
        [0, 3],
        [2, 0],
      ],
      [
        [0, 3],
        [3, 0],
      ],
      // Taller behind shorter (depth 1 needs +1; depth 2 needs +2).
      [
        [3, 0],
        [0, 1],
      ],
      [
        [4, 0],
        [0, 2],
      ],
      [
        [3, 2],
        [0, 1],
      ],
      [
        [4, 0],
        [1, 2],
      ],
      [
        [2, 0, 0],
        [0, 0, 0],
        [0, 0, 2],
      ],
      [
        [0, 2, 0],
        [2, 0, 2],
        [0, 2, 0],
      ],
      [
        [3, 0, 0],
        [0, 1, 0],
        [0, 0, 2],
      ],
      [
        [4, 0, 0],
        [0, 2, 0],
        [0, 0, 1],
      ],
      [
        [3, 0, 0],
        [0, 0, 0],
        [0, 0, 3],
      ],
      [
        [0, 0, 3],
        [0, 0, 0],
        [3, 0, 0],
      ],
      [
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 2],
      ],
      [
        [0, 3, 0, 0],
        [3, 0, 0, 0],
        [0, 0, 0, 3],
        [0, 0, 3, 0],
      ],
      [
        [4, 0, 0, 0],
        [0, 2, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 2],
      ],
    ];

    for (final template in candidates) {
      final heights = template.map((row) => List<int>.from(row)).toList();
      _removeOccludedColumns(heights);
      if (!_allOccupiedColumnsVisible(heights)) {
        continue;
      }
      final total = _totalCubes(heights);
      if (total < minTotal || total > maxTotal) {
        continue;
      }
      if (excluding != null && _sameLayout(heights, excluding.heights)) {
        continue;
      }
      return CubePuzzle(
        heights: heights,
        expectedTotal: total,
        level: level,
      );
    }

    // Guaranteed in-range layout: place stacks only on same-depth pairs /
    // isolated columns so nothing can sit behind an overlapping neighbor.
    final size = _gridSizeForLevel(level);
    final maxHeight = _maxHeightForLevel(level);
    final heights = List.generate(size, (_) => List.filled(size, 0));
    var remaining = minTotal.clamp(1, maxTotal);

    // Fill front-most same-depth diagonal cells first (no mutual occlusion).
    final cells = <(int, int)>[];
    for (var depth = size * 2 - 2; depth >= 0; depth--) {
      for (var r = 0; r < size; r++) {
        final c = depth - r;
        if (c < 0 || c >= size) {
          continue;
        }
        cells.add((r, c));
      }
    }

    for (final (r, c) in cells) {
      if (remaining <= 0) {
        break;
      }
      // Skip if any already-placed stack would hide this cell.
      final wouldHide = cells.any((other) {
        final (or, oc) = other;
        if (heights[or][oc] <= 0) {
          return false;
        }
        return _frontHidesBack(
          backRow: r,
          backCol: c,
          backHeight: 1,
          frontRow: or,
          frontCol: oc,
          frontHeight: heights[or][oc],
        );
      });
      if (wouldHide) {
        continue;
      }
      final stack = remaining.clamp(1, maxHeight);
      heights[r][c] = stack;
      remaining -= stack;
    }

    _removeOccludedColumns(heights);
    var total = _totalCubes(heights);
    if (total < minTotal) {
      // Grow the front-most occupied stack without introducing occlusion.
      for (var depth = size * 2 - 2; depth >= 0 && total < minTotal; depth--) {
        for (var r = 0; r < size && total < minTotal; r++) {
          final c = depth - r;
          if (c < 0 || c >= size || heights[r][c] <= 0) {
            continue;
          }
          final room = maxHeight - heights[r][c];
          if (room <= 0) {
            continue;
          }
          final add = (minTotal - total).clamp(1, room);
          heights[r][c] += add;
          total += add;
        }
      }
    }
    return CubePuzzle(
      heights: heights,
      expectedTotal: _totalCubes(heights),
      level: level,
    );
  }

  /// Early levels stay small (≤8). Growth is slow; totals rarely exceed 20.
  static int _maxTotalForLevel(int level) {
    // First two questions only: 2–3 cubes (never 1).
    if (level <= 2) {
      return 3;
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

  /// Never asks for 1 cube. Totals of 2–3 only on the first two questions.
  static int _minTotalForLevel(int level) {
    if (level <= 2) {
      return 2;
    }
    if (level <= 5) {
      return 4;
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
      return 0.2;
    }
    if (level <= 14) {
      return 0.25;
    }
    return 0.3;
  }
}
