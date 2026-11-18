import 'dart:math';

import 'package:brainiacs_flutter/features/analytical/domain/cube_puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CubePuzzle unambiguous visibility', () {
    test('generated puzzles stay uniquely countable across levels', () {
      for (final level in [1, 2, 3, 5, 8, 12, 16, 25, 40]) {
        for (var seed = 0; seed < 40; seed++) {
          final puzzle = CubePuzzle.generate(
            level,
            random: Random(seed * 31 + level),
          );
          expect(
            CubePuzzle.isUnambiguouslyVisible(puzzle.heights),
            isTrue,
            reason: 'level=$level seed=$seed heights=${puzzle.heights}',
          );
          expect(puzzle.expectedTotal, _total(puzzle.heights));
        }
      }
    });

    test('a shorter stack behind an overlapping taller stack is rejected', () {
      final ambiguous = [
        [3, 0],
        [0, 4],
      ];
      expect(CubePuzzle.isUnambiguouslyVisible(ambiguous), isFalse);
    });

    test('a taller stack that clears the front top stays', () {
      // Depth 1: (0,0) behind (0,1) needs at least +1 height.
      final depthOne = [
        [4, 2],
        [0, 0],
      ];
      expect(CubePuzzle.isUnambiguouslyVisible(depthOne), isTrue);

      // Depth 2 on the main diagonal needs at least +2 height.
      final depthTwo = [
        [4, 0],
        [0, 2],
      ];
      expect(CubePuzzle.isUnambiguouslyVisible(depthTwo), isTrue);
    });

    test('edge-adjacent equal heights stay visible', () {
      // |diagDiff| == 2: footprints touch at an edge but do not cover.
      final edgeAdjacent = [
        [2, 0, 2],
        [0, 0, 0],
        [0, 0, 0],
      ];
      expect(CubePuzzle.isUnambiguouslyVisible(edgeAdjacent), isTrue);
    });

    test('same-depth neighbors remain visible', () {
      final sideBySide = [
        [0, 2],
        [2, 0],
      ];
      expect(CubePuzzle.isUnambiguouslyVisible(sideBySide), isTrue);
    });

    test('mid-level seeds produce some real front/back pairs', () {
      var frontBackCount = 0;
      for (var seed = 0; seed < 80; seed++) {
        final puzzle = CubePuzzle.generate(10, random: Random(seed));
        expect(CubePuzzle.isUnambiguouslyVisible(puzzle.heights), isTrue);
        if (_hasFrontBackPair(puzzle.heights)) {
          frontBackCount++;
        }
      }
      expect(
        frontBackCount,
        greaterThan(0),
        reason: 'expected denser generation to keep some overlapping stacks',
      );
    });

    test('excluding still yields a different unambiguous layout', () {
      final first = CubePuzzle.generate(6, random: Random(7));
      final second = CubePuzzle.generate(
        6,
        random: Random(7),
        excluding: first,
      );
      expect(CubePuzzle.isUnambiguouslyVisible(second.heights), isTrue);
      expect(second.heights, isNot(first.heights));
    });
  });
}

int _total(List<List<int>> heights) {
  return heights.fold<int>(
    0,
    (sum, row) => sum + row.fold<int>(0, (rowSum, h) => rowSum + h),
  );
}

/// True when two occupied cells overlap on screen (depthDiff > 0, |diagDiff| < 2).
bool _hasFrontBackPair(List<List<int>> heights) {
  final rows = heights.length;
  final cols = heights.first.length;
  for (var br = 0; br < rows; br++) {
    for (var bc = 0; bc < cols; bc++) {
      if (heights[br][bc] <= 0) {
        continue;
      }
      for (var fr = 0; fr < rows; fr++) {
        for (var fc = 0; fc < cols; fc++) {
          if (heights[fr][fc] <= 0) {
            continue;
          }
          final depthDiff = (fr + fc) - (br + bc);
          if (depthDiff <= 0) {
            continue;
          }
          final diagDiff = ((fc - fr) - (bc - br)).abs();
          if (diagDiff < 2) {
            return true;
          }
        }
      }
    }
  }
  return false;
}
