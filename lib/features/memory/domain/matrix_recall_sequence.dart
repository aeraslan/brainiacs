import 'dart:math';

/// Generates Simon-style tile sequences for Matrix Recall.
abstract final class MatrixRecallSequence {
  static const int defaultGridSize = 3;
  static const int initialLength = 3;

  /// Builds a sequence of [length] tile indices in `0 .. tileCount - 1`.
  ///
  /// Consecutive duplicates are forbidden so a lit→gap→lit flash cannot look
  /// like one continuous light. When [excluding] is provided, the result is
  /// regenerated until it differs from that sequence.
  static List<int> generate({
    required int length,
    int gridSize = defaultGridSize,
    List<int>? excluding,
    Random? random,
  }) {
    assert(length >= 1, 'length must be at least 1');
    assert(gridSize >= 2, 'gridSize must be at least 2');

    final rng = random ?? Random();
    final tileCount = gridSize * gridSize;
    List<int> sequence;

    do {
      sequence = _buildOnce(
        length: length,
        tileCount: tileCount,
        random: rng,
      );
    } while (excluding != null && _listsEqual(sequence, excluding));

    return List<int>.unmodifiable(sequence);
  }

  static List<int> _buildOnce({
    required int length,
    required int tileCount,
    required Random random,
  }) {
    final result = <int>[];
    for (var i = 0; i < length; i++) {
      var next = random.nextInt(tileCount);
      if (result.isNotEmpty && tileCount > 1) {
        while (next == result.last) {
          next = random.nextInt(tileCount);
        }
      }
      result.add(next);
    }
    return result;
  }

  static bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
