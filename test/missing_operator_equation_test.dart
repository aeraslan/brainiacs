import 'dart:math';

import 'package:brainiacs_flutter/features/math/domain/math_equation.dart';
import 'package:brainiacs_flutter/features/math/domain/missing_operator_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('operator glyphs use typographic + - × and slash division', () {
    expect(MathOperator.add.symbol, '+');
    expect(MathOperator.subtract.symbol, '-');
    expect(MathOperator.multiply.symbol, '×');
    expect(MathOperator.divide.symbol, '/');
  });

  test('missing operator equations are unique and exact', () {
    final seedRng = Random(42);
    for (final count in [0, 4, 5, 9, 10, 20]) {
      for (var i = 0; i < 40; i++) {
        final eq = MissingOperatorEquation.forCorrectCount(
          count,
          random: Random(seedRng.nextInt(1 << 30)),
        );
        final eval = MissingOperatorEquation.evaluateCandidate(
          eq,
          eq.correctOperator,
        );
        expect(eval, eq.result, reason: eq.identityKey);

        var matches = 0;
        for (final op in MathOperator.values) {
          final value = MissingOperatorEquation.evaluateCandidate(eq, op);
          if (value == eq.result) {
            matches++;
          }
        }
        expect(matches, 1, reason: eq.identityKey);
      }
    }
  });

  test('levels map from correctCount', () {
    expect(
      MissingOperatorEquation.levelForCorrectCount(0),
      MissingOperatorLevel.one,
    );
    expect(
      MissingOperatorEquation.levelForCorrectCount(4),
      MissingOperatorLevel.one,
    );
    expect(
      MissingOperatorEquation.levelForCorrectCount(5),
      MissingOperatorLevel.two,
    );
    expect(
      MissingOperatorEquation.levelForCorrectCount(9),
      MissingOperatorLevel.two,
    );
    expect(
      MissingOperatorEquation.levelForCorrectCount(10),
      MissingOperatorLevel.three,
    );
  });

  test('level 2+ always uses parentheses layouts', () {
    final seedRng = Random(7);
    for (final count in [5, 9, 10, 15]) {
      for (var i = 0; i < 20; i++) {
        final eq = MissingOperatorEquation.forCorrectCount(
          count,
          random: Random(seedRng.nextInt(1 << 30)),
        );
        expect(
          eq.layout,
          anyOf(
            MissingOperatorLayout.parenMissingLeft,
            MissingOperatorLayout.parenMissingRight,
          ),
          reason: eq.identityKey,
        );
      }
    }
  });
}
