import 'dart:math';

import 'package:brainiacs_flutter/features/memory/domain/matrix_recall_sequence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate produces requested length within tile range', () {
    final seedRng = Random(42);
    for (var i = 0; i < 40; i++) {
      final length = 3 + seedRng.nextInt(8);
      final sequence = MatrixRecallSequence.generate(
        length: length,
        gridSize: 3,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(sequence, hasLength(length));
      for (final index in sequence) {
        expect(index, inInclusiveRange(0, 8));
      }
    }
  });

  test('generate never repeats consecutive indices', () {
    final seedRng = Random(99);
    for (var i = 0; i < 60; i++) {
      final sequence = MatrixRecallSequence.generate(
        length: 12,
        gridSize: 3,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      for (var j = 1; j < sequence.length; j++) {
        expect(
          sequence[j],
          isNot(sequence[j - 1]),
          reason: 'consecutive duplicate at $j in $sequence',
        );
      }
    }
  });

  test('excluding yields a different sequence', () {
    final original = MatrixRecallSequence.generate(
      length: 4,
      random: Random(7),
    );
    final next = MatrixRecallSequence.generate(
      length: 4,
      excluding: original,
      random: Random(7),
    );
    expect(next, isNot(original));
    expect(next, hasLength(4));
  });

  test('4x4 grid uses indices 0..15', () {
    final sequence = MatrixRecallSequence.generate(
      length: 6,
      gridSize: 4,
      random: Random(3),
    );
    expect(sequence, hasLength(6));
    for (final index in sequence) {
      expect(index, inInclusiveRange(0, 15));
    }
  });
}
