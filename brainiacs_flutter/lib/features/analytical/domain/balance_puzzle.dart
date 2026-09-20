import 'dart:math';

import 'balance_assets.dart';

enum BalanceLevel { one, two, three, four }

/// A single pan comparison. Each pan holds one or more object asset paths.
/// [leftWeight] / [rightWeight] are the sums of those objects' masses.
class BalanceScaleComparison {
  const BalanceScaleComparison({
    required this.leftItems,
    required this.rightItems,
    required this.leftWeight,
    required this.rightWeight,
  });

  /// Asset paths on the left pan (may repeat for 2× the same item).
  final List<String> leftItems;

  /// Asset paths on the right pan.
  final List<String> rightItems;
  final int leftWeight;
  final int rightWeight;

  bool get isBalanced => leftWeight == rightWeight;

  /// Positive when the right pan is heavier (clockwise tilt in turns).
  double get tiltSign {
    if (leftWeight == rightWeight) {
      return 0;
    }
    return leftWeight > rightWeight ? -1 : 1;
  }

  String get identityKey =>
      '${leftItems.join("+")}:$leftWeight|${rightItems.join("+")}:$rightWeight';
}

/// Puzzle: deduce the heaviest object from scale comparisons.
///
/// Every object in a puzzle comes from a single [objectSet] (animals or foods).
class BalancePuzzle {
  const BalancePuzzle({
    required this.level,
    required this.objectSet,
    required this.scales,
    required this.choices,
    required this.correctObjectId,
    required this.weightsByObject,
  });

  final BalanceLevel level;
  final BalanceObjectSet objectSet;
  final List<BalanceScaleComparison> scales;

  /// Asset paths shown as answer choices.
  final List<String> choices;

  /// Asset path of the uniquely heaviest object.
  final String correctObjectId;
  final Map<String, int> weightsByObject;

  String get identityKey {
    final scaleKeys = scales.map((s) => s.identityKey).join(';');
    return '$level|$objectSet|$correctObjectId|${choices.join(",")}|$scaleKeys';
  }

  static BalanceLevel levelForCorrectCount(int correctCount) {
    if (correctCount >= 8) {
      return BalanceLevel.four;
    }
    if (correctCount >= 5) {
      return BalanceLevel.three;
    }
    if (correctCount >= 2) {
      return BalanceLevel.two;
    }
    return BalanceLevel.one;
  }

  factory BalancePuzzle.forCorrectCount(
    int correctCount, {
    Random? random,
    BalancePuzzle? excluding,
  }) {
    final rng = random ?? Random();
    final level = levelForCorrectCount(correctCount);

    for (var attempt = 0; attempt < 64; attempt++) {
      final objectSet = rng.nextBool()
          ? BalanceObjectSet.animals
          : BalanceObjectSet.foods;
      final candidate = switch (level) {
        BalanceLevel.one => _generateLevelOne(rng, objectSet),
        BalanceLevel.two => _generateLevelTwo(rng, objectSet),
        BalanceLevel.three => _generateLevelThree(rng, objectSet),
        BalanceLevel.four => _generateLevelFour(rng, objectSet),
      };
      if (candidate == null) {
        continue;
      }
      if (excluding != null && candidate.identityKey == excluding.identityKey) {
        continue;
      }
      if (excluding != null &&
          candidate.correctObjectId == excluding.correctObjectId) {
        if (attempt < 40) {
          continue;
        }
      }
      return candidate;
    }

    return _fallbackFor(level);
  }

  static BalancePuzzle? _generateLevelOne(
    Random rng,
    BalanceObjectSet objectSet,
  ) {
    final objects = _pickObjects(rng, objectSet, 3);
    if (objects == null) {
      return null;
    }
    final weights = <String, int>{
      objects[0]: 3,
      objects[1]: 2,
      objects[2]: 1,
    };
    final heaviest = objects[0];
    final lighter = rng.nextBool() ? objects[1] : objects[2];

    final scale = _orientedSides([heaviest], [lighter], weights, rng);
    final choices = List<String>.from(objects)..shuffle(rng);

    return BalancePuzzle(
      level: BalanceLevel.one,
      objectSet: objectSet,
      scales: [scale],
      choices: choices,
      correctObjectId: heaviest,
      weightsByObject: weights,
    );
  }

  /// Two scales forming A > B > C. Answer is uniquely A.
  static BalancePuzzle? _generateLevelTwo(
    Random rng,
    BalanceObjectSet objectSet,
  ) {
    final objects = _pickObjects(rng, objectSet, 3);
    if (objects == null) {
      return null;
    }
    final a = objects[0];
    final b = objects[1];
    final c = objects[2];
    final weights = <String, int>{a: 3, b: 2, c: 1};

    final scaleAb = _orientedSides([a], [b], weights, rng);
    final scaleBc = _orientedSides([b], [c], weights, rng);

    final choices = List<String>.from(objects)..shuffle(rng);

    return BalancePuzzle(
      level: BalanceLevel.two,
      objectSet: objectSet,
      scales: [scaleAb, scaleBc],
      choices: choices,
      correctObjectId: a,
      weightsByObject: weights,
    );
  }

  /// 3-scale 1v1 tournament: A>B, C>D, A>C. Unique heaviest A.
  static BalancePuzzle? _generateLevelThree(
    Random rng,
    BalanceObjectSet objectSet,
  ) {
    final objects = _pickObjects(rng, objectSet, 4);
    if (objects == null) {
      return null;
    }
    final a = objects[0];
    final b = objects[1];
    final c = objects[2];
    final d = objects[3];
    final weights = {a: 4, b: 2, c: 3, d: 1};
    final scales = [
      _orientedSides([a], [b], weights, rng),
      _orientedSides([c], [d], weights, rng),
      _orientedSides([a], [c], weights, rng),
    ];
    return _assembleFourObjectPuzzle(
      rng: rng,
      objectSet: objectSet,
      level: BalanceLevel.three,
      objects: objects,
      heaviest: a,
      weights: weights,
      scales: scales,
    );
  }

  /// Cancellation tree: at least two compound pans, still unique heaviest A.
  static BalancePuzzle? _generateLevelFour(
    Random rng,
    BalanceObjectSet objectSet,
  ) {
    final objects = _pickObjects(rng, objectSet, 4);
    if (objects == null) {
      return null;
    }
    final a = objects[0];
    final b = objects[1];
    final c = objects[2];
    final d = objects[3];

    late final Map<String, int> weights;
    late final List<BalanceScaleComparison> scales;

    switch (rng.nextInt(3)) {
      case 0:
        // Double cancel + championship: 2A vs A+B, 2C vs C+D, A vs C.
        weights = {a: 4, b: 2, c: 3, d: 1};
        scales = [
          _orientedSides([a, a], [a, b], weights, rng),
          _orientedSides([c, c], [c, d], weights, rng),
          _orientedSides([a], [c], weights, rng),
        ];
      case 1:
        // Chain cancel: 2A vs A+B => A>B, 2B vs B+C => B>C, A vs D.
        weights = {a: 4, b: 3, c: 1, d: 2};
        scales = [
          _orientedSides([a, a], [a, b], weights, rng),
          _orientedSides([b, b], [b, c], weights, rng),
          _orientedSides([a], [d], weights, rng),
        ];
      default:
        // Championship is also a cancel: 2A vs A+B, C vs D, 2A vs A+C.
        weights = {a: 4, b: 2, c: 3, d: 1};
        scales = [
          _orientedSides([a, a], [a, b], weights, rng),
          _orientedSides([c], [d], weights, rng),
          _orientedSides([a, a], [a, c], weights, rng),
        ];
    }

    return _assembleFourObjectPuzzle(
      rng: rng,
      objectSet: objectSet,
      level: BalanceLevel.four,
      objects: objects,
      heaviest: a,
      weights: weights,
      scales: scales,
    );
  }

  static BalancePuzzle? _assembleFourObjectPuzzle({
    required Random rng,
    required BalanceObjectSet objectSet,
    required BalanceLevel level,
    required List<String> objects,
    required String heaviest,
    required Map<String, int> weights,
    required List<BalanceScaleComparison> scales,
  }) {
    if (_hasPileVersusSingle(scales)) {
      return null;
    }
    if (!_hasUniqueHeaviest(weights, heaviest)) {
      return null;
    }
    if (uniqueHeaviestImpliedBy(objects, scales) != heaviest) {
      return null;
    }

    scales.shuffle(rng);
    final choices = List<String>.from(objects)..shuffle(rng);

    return BalancePuzzle(
      level: level,
      objectSet: objectSet,
      scales: scales,
      choices: choices,
      correctObjectId: heaviest,
      weightsByObject: weights,
    );
  }

  static bool _hasUniqueHeaviest(Map<String, int> weights, String expected) {
    final maxWeight = weights.values.reduce((x, y) => x > y ? x : y);
    final heaviest = weights.entries
        .where((e) => e.value == maxWeight)
        .map((e) => e.key)
        .toList();
    return heaviest.length == 1 && heaviest.single == expected;
  }

  /// Heaviest object implied by the scales alone, or null if ambiguous.
  ///
  /// Tries distinct positive integer weights. If more than one object can be
  /// the unique maximum across valid worlds, the puzzle is ambiguous.
  static String? uniqueHeaviestImpliedBy(
    List<String> objects,
    List<BalanceScaleComparison> scales,
  ) {
    String? seen;
    var anyValid = false;

    for (final assignment in _distinctWeightAssignments(objects)) {
      if (!_scalesHold(scales, assignment)) {
        continue;
      }
      anyValid = true;
      final maxWeight = assignment.values.reduce((x, y) => x > y ? x : y);
      final tops = objects.where((id) => assignment[id] == maxWeight).toList();
      if (tops.length != 1) {
        return null;
      }
      final candidate = tops.single;
      if (seen == null) {
        seen = candidate;
      } else if (seen != candidate) {
        return null;
      }
    }

    if (!anyValid) {
      return null;
    }
    return seen;
  }

  static bool _scalesHold(
    List<BalanceScaleComparison> scales,
    Map<String, int> weights,
  ) {
    for (final scale in scales) {
      final left = _sumWeight(scale.leftItems, weights);
      final right = _sumWeight(scale.rightItems, weights);
      if (scale.isBalanced) {
        if (left != right) {
          return false;
        }
      } else if (scale.leftWeight > scale.rightWeight) {
        if (left <= right) {
          return false;
        }
      } else if (right <= left) {
        return false;
      }
    }
    return true;
  }

  static Iterable<Map<String, int>> _distinctWeightAssignments(
    List<String> objects, {
    int maxValue = 8,
  }) sync* {
    final n = objects.length;
    if (n == 0) {
      return;
    }
    final pool = [for (var v = 1; v <= maxValue; v++) v];
    for (final combo in _combinations(pool, n)) {
      for (final perm in _permutations(combo)) {
        yield {for (var i = 0; i < n; i++) objects[i]: perm[i]};
      }
    }
  }

  static Iterable<List<int>> _combinations(List<int> pool, int k) sync* {
    if (k == 0) {
      yield const [];
      return;
    }
    if (k > pool.length) {
      return;
    }
    for (var i = 0; i <= pool.length - k; i++) {
      for (final rest in _combinations(pool.sublist(i + 1), k - 1)) {
        yield [pool[i], ...rest];
      }
    }
  }

  static Iterable<List<int>> _permutations(List<int> items) sync* {
    if (items.length <= 1) {
      yield List<int>.from(items);
      return;
    }
    for (var i = 0; i < items.length; i++) {
      final rest = [...items.sublist(0, i), ...items.sublist(i + 1)];
      for (final perm in _permutations(rest)) {
        yield [items[i], ...perm];
      }
    }
  }

  static bool _hasPileVersusSingle(List<BalanceScaleComparison> scales) {
    for (final scale in scales) {
      final left = scale.leftItems.length;
      final right = scale.rightItems.length;
      if ((left >= 3 && right == 1) || (right >= 3 && left == 1)) {
        return true;
      }
    }
    return false;
  }

  static int _sumWeight(List<String> items, Map<String, int> weights) {
    var total = 0;
    for (final id in items) {
      total += weights[id]!;
    }
    return total;
  }

  static BalanceScaleComparison _orientedSides(
    List<String> sideA,
    List<String> sideB,
    Map<String, int> weights,
    Random rng,
  ) {
    final weightA = _sumWeight(sideA, weights);
    final weightB = _sumWeight(sideB, weights);
    if (rng.nextBool()) {
      return BalanceScaleComparison(
        leftItems: List<String>.from(sideA),
        rightItems: List<String>.from(sideB),
        leftWeight: weightA,
        rightWeight: weightB,
      );
    }
    return BalanceScaleComparison(
      leftItems: List<String>.from(sideB),
      rightItems: List<String>.from(sideA),
      leftWeight: weightB,
      rightWeight: weightA,
    );
  }

  static List<String>? _pickObjects(
    Random rng,
    BalanceObjectSet objectSet,
    int count,
  ) {
    final pool = List<String>.from(BalanceAssets.poolFor(objectSet));
    if (pool.length < count) {
      return null;
    }
    pool.shuffle(rng);
    return pool.take(count).toList();
  }

  static BalancePuzzle _fallbackFor(BalanceLevel level) {
    const a = 'assets/balance/animals/bear.png';
    const b = 'assets/balance/animals/rabbit.png';
    const c = 'assets/balance/animals/penguin.png';
    const d = 'assets/balance/animals/frog.png';

    return switch (level) {
      BalanceLevel.one => const BalancePuzzle(
        level: BalanceLevel.one,
        objectSet: BalanceObjectSet.animals,
        scales: [
          BalanceScaleComparison(
            leftItems: [a],
            rightItems: [b],
            leftWeight: 3,
            rightWeight: 1,
          ),
        ],
        choices: [a, b, c],
        correctObjectId: a,
        weightsByObject: {a: 3, b: 1, c: 2},
      ),
      BalanceLevel.two => const BalancePuzzle(
        level: BalanceLevel.two,
        objectSet: BalanceObjectSet.animals,
        scales: [
          BalanceScaleComparison(
            leftItems: [a],
            rightItems: [b],
            leftWeight: 3,
            rightWeight: 2,
          ),
          BalanceScaleComparison(
            leftItems: [b],
            rightItems: [c],
            leftWeight: 2,
            rightWeight: 1,
          ),
        ],
        choices: [a, b, c],
        correctObjectId: a,
        weightsByObject: {a: 3, b: 2, c: 1},
      ),
      BalanceLevel.three => const BalancePuzzle(
        level: BalanceLevel.three,
        objectSet: BalanceObjectSet.animals,
        scales: [
          BalanceScaleComparison(
            leftItems: [a],
            rightItems: [b],
            leftWeight: 4,
            rightWeight: 2,
          ),
          BalanceScaleComparison(
            leftItems: [c],
            rightItems: [d],
            leftWeight: 3,
            rightWeight: 1,
          ),
          BalanceScaleComparison(
            leftItems: [a],
            rightItems: [c],
            leftWeight: 4,
            rightWeight: 3,
          ),
        ],
        choices: [a, b, c, d],
        correctObjectId: a,
        weightsByObject: {a: 4, b: 2, c: 3, d: 1},
      ),
      BalanceLevel.four => const BalancePuzzle(
        level: BalanceLevel.four,
        objectSet: BalanceObjectSet.animals,
        scales: [
          BalanceScaleComparison(
            leftItems: [a, a],
            rightItems: [a, b],
            leftWeight: 8,
            rightWeight: 6,
          ),
          BalanceScaleComparison(
            leftItems: [c, c],
            rightItems: [c, d],
            leftWeight: 6,
            rightWeight: 4,
          ),
          BalanceScaleComparison(
            leftItems: [a],
            rightItems: [c],
            leftWeight: 4,
            rightWeight: 3,
          ),
        ],
        choices: [a, b, c, d],
        correctObjectId: a,
        weightsByObject: {a: 4, b: 2, c: 3, d: 1},
      ),
    };
  }
}
