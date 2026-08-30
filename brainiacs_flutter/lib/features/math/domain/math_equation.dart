import 'dart:math';

enum MathOperator {
  add('+'),
  subtract('-'),
  multiply('×');

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

  int get requiredDigitCount => correctAnswer.abs().toString().length;

  factory MathEquation.forLevel(int level, [Random? random]) {
    final rng = random ?? Random();
    final config = _DifficultyConfig.forLevel(level);

    if (config.allowParentheses &&
        rng.nextDouble() < config.parenthesesChance) {
      return _GroupedMathEquation.generate(level, config, rng);
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

  static _BinaryMathEquation generate(
    int level,
    _DifficultyConfig config,
    Random rng,
  ) {
    final operators = _allowedOperators(level, config);
    final operator = operators[rng.nextInt(operators.length)];

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
          right = config.minOperand;
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
    };

    return switch (layout) {
      _GroupedLayout.multiplierFirst => '$multiplier×($inner)=',
      _GroupedLayout.multiplierLast => '($inner)×$multiplier=',
    };
  }

  static _GroupedMathEquation generate(
    int level,
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
      innerLeft = _randomInRange(config.minGroupedInner, config.maxGroupedInner, rng);
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
  final bool allowParentheses;
  final double parenthesesChance;
  final int minGroupedInner;
  final int maxGroupedInner;

  factory _DifficultyConfig.forLevel(int level) {
    if (level >= 15) {
      return _DifficultyConfig(
        minOperand: 12,
        maxAddSub: 99,
        allowMultiply: true,
        minMultiplyFactor: 4,
        maxMultiplyFactor: 15,
        allowParentheses: true,
        parenthesesChance: 0.5,
        minGroupedInner: 10,
        maxGroupedInner: 30,
      );
    }
    if (level >= 10) {
      return _DifficultyConfig(
        minOperand: 8,
        maxAddSub: 75,
        allowMultiply: true,
        minMultiplyFactor: 3,
        maxMultiplyFactor: 12,
        allowParentheses: true,
        parenthesesChance: 0.35,
        minGroupedInner: 5,
        maxGroupedInner: 20,
      );
    }
    if (level >= 7) {
      return _DifficultyConfig(
        minOperand: 5,
        maxAddSub: 50,
        allowMultiply: true,
        minMultiplyFactor: 3,
        maxMultiplyFactor: 12,
        allowParentheses: false,
        parenthesesChance: 0,
        minGroupedInner: 0,
        maxGroupedInner: 0,
      );
    }
    if (level >= 5) {
      return _DifficultyConfig(
        minOperand: 3,
        maxAddSub: 30,
        allowMultiply: true,
        minMultiplyFactor: 2,
        maxMultiplyFactor: 9,
        allowParentheses: false,
        parenthesesChance: 0,
        minGroupedInner: 0,
        maxGroupedInner: 0,
      );
    }
    if (level >= 3) {
      return _DifficultyConfig(
        minOperand: 2,
        maxAddSub: 20,
        allowMultiply: false,
        minMultiplyFactor: 0,
        maxMultiplyFactor: 0,
        allowParentheses: false,
        parenthesesChance: 0,
        minGroupedInner: 0,
        maxGroupedInner: 0,
      );
    }
    if (level >= 2) {
      return _DifficultyConfig(
        minOperand: 1,
        maxAddSub: 10,
        allowMultiply: false,
        minMultiplyFactor: 0,
        maxMultiplyFactor: 0,
        allowParentheses: false,
        parenthesesChance: 0,
        minGroupedInner: 0,
        maxGroupedInner: 0,
      );
    }

    return const _DifficultyConfig(
      minOperand: 1,
      maxAddSub: 10,
      allowMultiply: false,
      minMultiplyFactor: 0,
      maxMultiplyFactor: 0,
      allowParentheses: false,
      parenthesesChance: 0,
      minGroupedInner: 0,
      maxGroupedInner: 0,
    );
  }
}

List<MathOperator> _allowedOperators(int level, _DifficultyConfig config) {
  if (level <= 1) {
    return const [MathOperator.add];
  }
  if (!config.allowMultiply) {
    return const [MathOperator.add, MathOperator.subtract];
  }
  return MathOperator.values;
}

int _randomInRange(int min, int max, Random rng) {
  if (min >= max) {
    return min;
  }
  return min + rng.nextInt(max - min + 1);
}
