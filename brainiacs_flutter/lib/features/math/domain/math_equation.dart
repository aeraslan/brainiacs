import 'dart:math';

enum MathOperator {
  add('+'),
  subtract('-'),
  multiply('×'),
  divide('÷');

  const MathOperator(this.symbol);

  final String symbol;
}

enum _GroupedLayout {
  multiplierFirst,
  multiplierLast,
}

sealed class MathEquation {
  const MathEquation();

  int get correctAnswer;

  String get displayText;

  /// Rough difficulty used to keep consecutive questions from swinging too soft.
  int get difficultyScore;

  int get requiredDigitCount => correctAnswer.abs().toString().length;

  factory MathEquation.forLevel(
    int level, {
    Random? random,
    int? minDifficultyScore,
  }) {
    final rng = random ?? Random();
    final config = _DifficultyConfig.forLevel(level);
    final floor = minDifficultyScore == null
        ? 0
        : max(0, (minDifficultyScore * 0.72).round());

    MathEquation best = _generateOnce(level, config, rng);
    if (floor <= 0) {
      return best;
    }

    for (var attempt = 0; attempt < 12; attempt++) {
      final candidate = _generateOnce(level, config, rng);
      if (candidate.difficultyScore >= floor) {
        return candidate;
      }
      if (candidate.difficultyScore > best.difficultyScore) {
        best = candidate;
      }
    }
    return best;
  }

  static MathEquation _generateOnce(
    int level,
    _DifficultyConfig config,
    Random rng,
  ) {
    if (config.allowParentheses &&
        rng.nextDouble() < config.parenthesesChance) {
      return _GroupedMathEquation.generate(config, rng);
    }
    return _BinaryMathEquation.generate(level, config, rng);
  }
}

final class _BinaryMathEquation extends MathEquation {
  const _BinaryMathEquation({
    required this.left,
    required this.right,
    required this.operator,
    required this.correctAnswer,
  });

  final int left;
  final int right;
  final MathOperator operator;
  @override
  final int correctAnswer;

  @override
  String get displayText => '$left ${operator.symbol} $right =';

  @override
  int get difficultyScore {
    final magnitude = left.abs() + right.abs() + correctAnswer.abs();
    final opWeight = switch (operator) {
      MathOperator.add => 8,
      MathOperator.subtract => 12,
      MathOperator.multiply => 28,
      MathOperator.divide => 34,
    };
    return opWeight + (magnitude ~/ 4);
  }

  static _BinaryMathEquation generate(
    int level,
    _DifficultyConfig config,
    Random rng,
  ) {
    final operator = _pickOperator(level, config, rng);

    var left = 0;
    var right = 0;
    var correctAnswer = 0;

    switch (operator) {
      case MathOperator.add:
        left = _randomInRange(config.minOperand, config.maxAddSub, rng);
        right = _randomInRange(config.minOperand, config.maxAddSub, rng);
        correctAnswer = left + right;
      case MathOperator.subtract:
        final a = _randomInRange(config.minOperand, config.maxAddSub, rng);
        final b = _randomInRange(config.minOperand, config.maxAddSub, rng);
        left = a >= b ? a : b;
        right = a >= b ? b : a;
        if (left == right && config.minOperand < config.maxAddSub) {
          right = max(config.minOperand, left - 1);
        }
        correctAnswer = left - right;
      case MathOperator.multiply:
        left = _randomInRange(
          config.minMultiplyFactor,
          config.maxMultiplyFactor,
          rng,
        );
        right = _randomInRange(
          config.minMultiplyFactor,
          config.maxMultiplyFactor,
          rng,
        );
        correctAnswer = left * right;
      case MathOperator.divide:
        final divisor = _randomInRange(
          config.minDivideDivisor,
          config.maxDivideDivisor,
          rng,
        );
        final quotient = _randomInRange(
          config.minDivideQuotient,
          config.maxDivideQuotient,
          rng,
        );
        left = divisor * quotient;
        right = divisor;
        correctAnswer = quotient;
    }

    return _BinaryMathEquation(
      left: left,
      right: right,
      operator: operator,
      correctAnswer: correctAnswer,
    );
  }
}

final class _GroupedMathEquation extends MathEquation {
  const _GroupedMathEquation({
    required this.layout,
    required this.multiplier,
    required this.innerLeft,
    required this.innerRight,
    required this.innerOperator,
    required this.correctAnswer,
  });

  final _GroupedLayout layout;
  final int multiplier;
  final int innerLeft;
  final int innerRight;
  final MathOperator innerOperator;
  @override
  final int correctAnswer;

  @override
  String get displayText {
    final inner = switch (innerOperator) {
      MathOperator.add => '$innerLeft+$innerRight',
      MathOperator.subtract => '$innerLeft-$innerRight',
      MathOperator.multiply => '$innerLeft×$innerRight',
      MathOperator.divide => '$innerLeft÷$innerRight',
    };

    return switch (layout) {
      _GroupedLayout.multiplierFirst => '$multiplier×($inner)=',
      _GroupedLayout.multiplierLast => '($inner)×$multiplier=',
    };
  }

  @override
  int get difficultyScore {
    final magnitude =
        multiplier + innerLeft + innerRight + correctAnswer.abs();
    return 48 + (magnitude ~/ 3);
  }

  static _GroupedMathEquation generate(
    _DifficultyConfig config,
    Random rng,
  ) {
    final layout = rng.nextBool()
        ? _GroupedLayout.multiplierFirst
        : _GroupedLayout.multiplierLast;
    final innerOperator = rng.nextBool()
        ? MathOperator.add
        : MathOperator.subtract;

    final multiplier = _randomInRange(
      config.minMultiplyFactor,
      config.maxMultiplyFactor,
      rng,
    );

    late final int innerLeft;
    late final int innerRight;

    if (innerOperator == MathOperator.add) {
      innerLeft =
          _randomInRange(config.minGroupedInner, config.maxGroupedInner, rng);
      innerRight =
          _randomInRange(config.minGroupedInner, config.maxGroupedInner, rng);
    } else {
      innerLeft = _randomInRange(
        config.minGroupedInner + 2,
        config.maxGroupedInner,
        rng,
      );
      innerRight = _randomInRange(config.minGroupedInner, innerLeft - 1, rng);
    }

    final innerResult = switch (innerOperator) {
      MathOperator.add => innerLeft + innerRight,
      MathOperator.subtract => innerLeft - innerRight,
      MathOperator.multiply => innerLeft * innerRight,
      MathOperator.divide => innerLeft ~/ innerRight,
    };

    return _GroupedMathEquation(
      layout: layout,
      multiplier: multiplier,
      innerLeft: innerLeft,
      innerRight: innerRight,
      innerOperator: innerOperator,
      correctAnswer: multiplier * innerResult,
    );
  }
}

class _DifficultyConfig {
  const _DifficultyConfig({
    required this.minOperand,
    required this.maxAddSub,
    required this.allowMultiply,
    required this.minMultiplyFactor,
    required this.maxMultiplyFactor,
    required this.allowDivide,
    required this.minDivideDivisor,
    required this.maxDivideDivisor,
    required this.minDivideQuotient,
    required this.maxDivideQuotient,
    required this.allowParentheses,
    required this.parenthesesChance,
    required this.minGroupedInner,
    required this.maxGroupedInner,
  });

  final int minOperand;
  final int maxAddSub;
  final bool allowMultiply;
  final int minMultiplyFactor;
  final int maxMultiplyFactor;
  final bool allowDivide;
  final int minDivideDivisor;
  final int maxDivideDivisor;
  final int minDivideQuotient;
  final int maxDivideQuotient;
  final bool allowParentheses;
  final double parenthesesChance;
  final int minGroupedInner;
  final int maxGroupedInner;

  factory _DifficultyConfig.forLevel(int level) {
    final lv = level < 1 ? 1 : level;

    // Smooth continuum — no big cliff between adjacent levels.
    final minOperand = _lerpInt(1, 18, lv, peakAt: 16);
    final maxAddSub = _lerpInt(10, 99, lv, peakAt: 16);
    final minMul = lv < 4 ? 0 : _lerpInt(2, 5, lv, peakAt: 14);
    final maxMul = lv < 4 ? 0 : _lerpInt(6, 14, lv, peakAt: 14);
    final minDivisor = lv < 6 ? 0 : _lerpInt(2, 4, lv, peakAt: 15);
    final maxDivisor = lv < 6 ? 0 : _lerpInt(5, 12, lv, peakAt: 15);
    final minQuotient = lv < 6 ? 0 : _lerpInt(2, 4, lv, peakAt: 15);
    final maxQuotient = lv < 6 ? 0 : _lerpInt(6, 14, lv, peakAt: 15);
    final minGrouped = lv < 8 ? 0 : _lerpInt(3, 10, lv, peakAt: 16);
    final maxGrouped = lv < 8 ? 0 : _lerpInt(10, 28, lv, peakAt: 16);

    final parenthesesChance = lv < 8
        ? 0.0
        : ((lv - 7) * 0.06).clamp(0.12, 0.48);

    return _DifficultyConfig(
      minOperand: minOperand,
      maxAddSub: maxAddSub,
      allowMultiply: lv >= 4,
      minMultiplyFactor: max(2, minMul),
      maxMultiplyFactor: max(minMul + 1, maxMul),
      allowDivide: lv >= 6,
      minDivideDivisor: max(2, minDivisor),
      maxDivideDivisor: max(minDivisor + 1, maxDivisor),
      minDivideQuotient: max(2, minQuotient),
      maxDivideQuotient: max(minQuotient + 1, maxQuotient),
      allowParentheses: lv >= 8,
      parenthesesChance: parenthesesChance,
      minGroupedInner: max(2, minGrouped),
      maxGroupedInner: max(minGrouped + 2, maxGrouped),
    );
  }

  /// Linear ramp from [start] to [end] across levels 1..[peakAt].
  static int _lerpInt(int start, int end, int level, {required int peakAt}) {
    if (level <= 1) {
      return start;
    }
    final t = ((level - 1) / (peakAt - 1)).clamp(0.0, 1.0);
    return (start + (end - start) * t).round();
  }
}

MathOperator _pickOperator(int level, _DifficultyConfig config, Random rng) {
  final weights = <MathOperator, double>{
    MathOperator.add: level <= 1
        ? 1
        : level <= 3
            ? 0.55
            : level <= 7
                ? 0.28
                : 0.14,
    MathOperator.subtract: level <= 1
        ? 0
        : level <= 3
            ? 0.45
            : level <= 7
                ? 0.28
                : 0.16,
  };

  if (config.allowMultiply) {
    weights[MathOperator.multiply] = level <= 5
        ? 0.35
        : level <= 9
            ? 0.34
            : 0.32;
  }
  if (config.allowDivide) {
    weights[MathOperator.divide] = level <= 8
        ? 0.22
        : level <= 12
            ? 0.28
            : 0.32;
  }

  final total = weights.values.fold<double>(0, (sum, w) => sum + w);
  var roll = rng.nextDouble() * total;
  for (final entry in weights.entries) {
    roll -= entry.value;
    if (roll <= 0) {
      return entry.key;
    }
  }
  return weights.keys.last;
}

int _randomInRange(int min, int max, Random rng) {
  if (min >= max) {
    return min;
  }
  return min + rng.nextInt(max - min + 1);
}
