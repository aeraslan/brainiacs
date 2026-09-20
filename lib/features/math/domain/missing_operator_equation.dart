import 'dart:math';

import 'math_equation.dart';

enum MissingOperatorLevel { one, two, three }

enum MissingOperatorLayout {
  binary,
  parenMissingLeft,
  parenMissingRight,
}

/// Equation with exactly one missing operator slot and a unique correct answer.
class MissingOperatorEquation {
  const MissingOperatorEquation({
    required this.layout,
    required this.a,
    required this.b,
    required this.result,
    required this.correctOperator,
    this.c,
    this.knownOperator,
  });

  final MissingOperatorLayout layout;
  final int a;
  final int b;
  final int? c;
  final int result;
  final MathOperator correctOperator;
  final MathOperator? knownOperator;

  String get identityKey {
    return '$layout|$a|$b|${c ?? ''}|${knownOperator?.symbol ?? ''}|'
        '${correctOperator.symbol}|$result';
  }

  static MissingOperatorLevel levelForCorrectCount(int correctCount) {
    if (correctCount >= 10) {
      return MissingOperatorLevel.three;
    }
    if (correctCount >= 5) {
      return MissingOperatorLevel.two;
    }
    return MissingOperatorLevel.one;
  }

  factory MissingOperatorEquation.forCorrectCount(
    int correctCount, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final level = levelForCorrectCount(correctCount);

    for (var attempt = 0; attempt < 48; attempt++) {
      final candidate = switch (level) {
        // Level 2 always uses explicit left grouping: (A [?] B) op C = D
        // so expressions like 3 ? 2 + 11 are never shown without parentheses.
        MissingOperatorLevel.one => _generateBinary(rng),
        MissingOperatorLevel.two => _generateParenLeft(rng),
        MissingOperatorLevel.three =>
          rng.nextBool() ? _generateParenLeft(rng) : _generateParenRight(rng),
      };
      if (candidate != null) {
        return candidate;
      }
    }

    // Extremely unlikely fallback — always unique for add with unequal operands.
    return const MissingOperatorEquation(
      layout: MissingOperatorLayout.binary,
      a: 3,
      b: 5,
      result: 8,
      correctOperator: MathOperator.add,
    );
  }

  static MissingOperatorEquation? _generateBinary(Random rng) {
    final op = _pickOperator(rng);
    final operands = _operandsForBinary(op, rng, maxOperand: 12);
    if (operands == null) {
      return null;
    }
    final (left, right, result) = operands;
    final equation = MissingOperatorEquation(
      layout: MissingOperatorLayout.binary,
      a: left,
      b: right,
      result: result,
      correctOperator: op,
    );
    return _hasUniqueAnswer(equation) ? equation : null;
  }

  static MissingOperatorEquation? _generateParenLeft(Random rng) {
    final missing = _pickOperator(rng);
    final known = _pickOperator(rng, preferAddSub: true);
    final maxOp = 12;

    final inner = _operandsForBinary(missing, rng, maxOperand: maxOp);
    if (inner == null) {
      return null;
    }
    final (a, b, innerResult) = inner;
    final knownOperands = _completeKnown(innerResult, known, rng, maxOp);
    if (knownOperands == null || knownOperands.$2 < 0) {
      return null;
    }

    final equation = MissingOperatorEquation(
      layout: MissingOperatorLayout.parenMissingLeft,
      a: a,
      b: b,
      c: knownOperands.$1,
      knownOperator: known,
      result: knownOperands.$2,
      correctOperator: missing,
    );
    return _hasUniqueAnswer(equation) ? equation : null;
  }

  static MissingOperatorEquation? _generateParenRight(Random rng) {
    final missing = _pickOperator(rng);
    final known = _pickOperator(rng, preferAddSub: true);
    final maxOp = 12;

    final inner = _operandsForBinary(missing, rng, maxOperand: maxOp);
    if (inner == null) {
      return null;
    }
    final (b, c, innerResult) = inner;

    late final int a;
    late final int result;

    switch (known) {
      case MathOperator.add:
        a = _randomInRange(1, maxOp, rng);
        result = a + innerResult;
      case MathOperator.subtract:
        a = innerResult + _randomInRange(0, maxOp, rng);
        result = a - innerResult;
      case MathOperator.multiply:
        a = _randomInRange(2, 8, rng);
        result = a * innerResult;
        if (result > 120) {
          return null;
        }
      case MathOperator.divide:
        if (innerResult == 0) {
          return null;
        }
        final quotient = _randomInRange(2, 10, rng);
        a = innerResult * quotient;
        result = quotient;
    }

    if (result < 0) {
      return null;
    }

    final equation = MissingOperatorEquation(
      layout: MissingOperatorLayout.parenMissingRight,
      a: a,
      b: b,
      c: c,
      knownOperator: known,
      result: result,
      correctOperator: missing,
    );
    return _hasUniqueAnswer(equation) ? equation : null;
  }

  /// Returns (rightOperand, result) after applying [known] to [left].
  static (int, int)? _completeKnown(
    int left,
    MathOperator known,
    Random rng,
    int maxOp,
  ) {
    switch (known) {
      case MathOperator.add:
        final right = _randomInRange(1, maxOp, rng);
        return (right, left + right);
      case MathOperator.subtract:
        if (left <= 0) {
          return null;
        }
        final right = _randomInRange(1, left, rng);
        return (right, left - right);
      case MathOperator.multiply:
        final right = _randomInRange(2, 9, rng);
        final product = left * right;
        if (product > 144) {
          return null;
        }
        return (right, product);
      case MathOperator.divide:
        if (left <= 1) {
          return null;
        }
        final divisors = <int>[];
        for (var d = 2; d <= min(left, 12); d++) {
          if (left % d == 0) {
            divisors.add(d);
          }
        }
        if (divisors.isEmpty) {
          return null;
        }
        final right = divisors[rng.nextInt(divisors.length)];
        return (right, left ~/ right);
    }
  }

  static (int, int, int)? _operandsForBinary(
    MathOperator op,
    Random rng, {
    required int maxOperand,
  }) {
    switch (op) {
      case MathOperator.add:
        final left = _randomInRange(1, maxOperand, rng);
        final right = _randomInRange(1, maxOperand, rng);
        return (left, right, left + right);
      case MathOperator.subtract:
        final left = _randomInRange(2, maxOperand, rng);
        final right = _randomInRange(1, left, rng);
        return (left, right, left - right);
      case MathOperator.multiply:
        final left = _randomInRange(2, min(10, maxOperand), rng);
        final right = _randomInRange(2, min(10, maxOperand), rng);
        final product = left * right;
        if (product > 100) {
          return null;
        }
        return (left, right, product);
      case MathOperator.divide:
        final pair = _exactDividePair(
          rng,
          maxQuotient: min(12, maxOperand),
          maxDivisor: min(10, maxOperand),
        );
        if (pair == null) {
          return null;
        }
        return (pair.$1, pair.$2, pair.$1 ~/ pair.$2);
    }
  }

  static (int, int)? _exactDividePair(
    Random rng, {
    required int maxQuotient,
    required int maxDivisor,
  }) {
    final divisor = _randomInRange(2, maxDivisor, rng);
    final quotient = _randomInRange(2, maxQuotient, rng);
    return (divisor * quotient, divisor);
  }

  static MathOperator _pickOperator(Random rng, {bool preferAddSub = false}) {
    if (preferAddSub && rng.nextDouble() < 0.55) {
      return rng.nextBool() ? MathOperator.add : MathOperator.subtract;
    }
    const ops = MathOperator.values;
    return ops[rng.nextInt(ops.length)];
  }

  static bool _hasUniqueAnswer(MissingOperatorEquation equation) {
    var matches = 0;
    for (final op in MathOperator.values) {
      final value = _evaluateWith(equation, op);
      if (value != null && value == equation.result) {
        matches++;
        if (matches > 1) {
          return false;
        }
      }
    }
    return matches == 1;
  }

  /// Result when [candidate] fills the missing slot, or null if invalid.
  static int? evaluateCandidate(
    MissingOperatorEquation equation,
    MathOperator candidate,
  ) {
    return _evaluateWith(equation, candidate);
  }

  bool isCorrect(MathOperator candidate) => candidate == correctOperator;

  static int? _evaluateWith(
    MissingOperatorEquation equation,
    MathOperator candidate,
  ) {
    switch (equation.layout) {
      case MissingOperatorLayout.binary:
        return _apply(equation.a, candidate, equation.b);
      case MissingOperatorLayout.parenMissingLeft:
        final known = equation.knownOperator;
        final c = equation.c;
        if (known == null || c == null) {
          return null;
        }
        final inner = _apply(equation.a, candidate, equation.b);
        if (inner == null) {
          return null;
        }
        return _apply(inner, known, c);
      case MissingOperatorLayout.parenMissingRight:
        final known = equation.knownOperator;
        final c = equation.c;
        if (known == null || c == null) {
          return null;
        }
        final inner = _apply(equation.b, candidate, c);
        if (inner == null) {
          return null;
        }
        return _apply(equation.a, known, inner);
    }
  }

  static int? _apply(int left, MathOperator op, int right) {
    switch (op) {
      case MathOperator.add:
        return left + right;
      case MathOperator.subtract:
        return left - right;
      case MathOperator.multiply:
        return left * right;
      case MathOperator.divide:
        if (right == 0 || left % right != 0) {
          return null;
        }
        return left ~/ right;
    }
  }

  static int _randomInRange(int min, int max, Random rng) {
    if (min >= max) {
      return min;
    }
    return min + rng.nextInt(max - min + 1);
  }
}
