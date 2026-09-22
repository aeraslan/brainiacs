import 'dart:math';

import 'package:brainiacs_flutter/features/analytical/domain/balance_assets.dart';
import 'package:brainiacs_flutter/features/analytical/domain/balance_puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('levels map from correctCount', () {
    expect(BalancePuzzle.levelForCorrectCount(0), BalanceLevel.one);
    expect(BalancePuzzle.levelForCorrectCount(2), BalanceLevel.one);
    expect(BalancePuzzle.levelForCorrectCount(3), BalanceLevel.two);
    expect(BalancePuzzle.levelForCorrectCount(5), BalanceLevel.two);
    expect(BalancePuzzle.levelForCorrectCount(6), BalanceLevel.three);
    expect(BalancePuzzle.levelForCorrectCount(9), BalanceLevel.three);
    expect(BalancePuzzle.levelForCorrectCount(10), BalanceLevel.four);
    expect(BalancePuzzle.levelForCorrectCount(20), BalanceLevel.four);
  });

  test('level 1 has one scale, three choices, unique heaviest', () {
    final seedRng = Random(42);
    for (var i = 0; i < 40; i++) {
      final puzzle = BalancePuzzle.forCorrectCount(
        0,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(puzzle.level, BalanceLevel.one);
      expect(puzzle.scales, hasLength(1));
      expect(puzzle.choices, hasLength(3));
      expect(puzzle.choices.toSet(), hasLength(3));
      expect(puzzle.choices, contains(puzzle.correctObjectId));
      _expectUniqueHeaviest(puzzle);
      _expectScaleWeightsMatch(puzzle);
      _expectSingleObjectSet(puzzle);
      _expectSingleItemPans(puzzle);
    }
  });

  test('level 2 is a transitive chain with two scales', () {
    final seedRng = Random(99);
    for (var i = 0; i < 40; i++) {
      final puzzle = BalancePuzzle.forCorrectCount(
        3,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(puzzle.level, BalanceLevel.two);
      expect(puzzle.scales, hasLength(2));
      expect(puzzle.choices, hasLength(3));
      _expectUniqueHeaviest(puzzle);
      _expectScaleWeightsMatch(puzzle);
      _expectSingleObjectSet(puzzle);
      _expectSingleItemPans(puzzle);

      for (final scale in puzzle.scales) {
        expect(scale.isBalanced, isFalse);
      }

      final heaviest = puzzle.correctObjectId;
      final appearsAsHeavier = puzzle.scales.any((s) {
        final heavier = s.leftWeight > s.rightWeight
            ? s.leftItems.first
            : s.rightItems.first;
        return heavier == heaviest;
      });
      expect(appearsAsHeavier, isTrue, reason: puzzle.identityKey);

      final leftPair = {
        puzzle.scales[0].leftItems.first,
        puzzle.scales[0].rightItems.first,
      };
      final rightPair = {
        puzzle.scales[1].leftItems.first,
        puzzle.scales[1].rightItems.first,
      };
      expect(leftPair.intersection(rightPair), isNotEmpty);
    }
  });

  test('level 3 is a uniquely solvable 1v1 tournament tree', () {
    final seedRng = Random(7);
    for (var i = 0; i < 40; i++) {
      final puzzle = BalancePuzzle.forCorrectCount(
        6 + (i % 4),
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(puzzle.level, BalanceLevel.three);
      expect(puzzle.scales, hasLength(3));
      expect(puzzle.choices, hasLength(4));
      expect(puzzle.choices.toSet(), hasLength(4));
      _expectUniqueHeaviest(puzzle);
      _expectScaleWeightsMatch(puzzle);
      _expectSingleObjectSet(puzzle);
      _expectSingleItemPans(puzzle);
      expect(
        BalancePuzzle.uniqueHeaviestImpliedBy(puzzle.choices, puzzle.scales),
        puzzle.correctObjectId,
        reason: puzzle.identityKey,
      );
    }
  });

  test('level 4 uses disjoint compound pans that defeat frequency guessing', () {
    final seedRng = Random(21);
    for (var i = 0; i < 40; i++) {
      final puzzle = BalancePuzzle.forCorrectCount(
        10 + (i % 8),
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(puzzle.level, BalanceLevel.four);
      expect(puzzle.scales, hasLength(3));
      expect(puzzle.choices, hasLength(4));
      _expectUniqueHeaviest(puzzle);
      _expectScaleWeightsMatch(puzzle);
      _expectSingleObjectSet(puzzle);
      final compoundCount = puzzle.scales.where((s) {
        return s.leftItems.length >= 2 || s.rightItems.length >= 2;
      }).length;
      expect(compoundCount, greaterThanOrEqualTo(2), reason: puzzle.identityKey);
      for (final scale in puzzle.scales) {
        expect(scale.leftItems.length, lessThanOrEqualTo(2));
        expect(scale.rightItems.length, lessThanOrEqualTo(2));
        final pileVsSingle =
            (scale.leftItems.length >= 3 && scale.rightItems.length == 1) ||
            (scale.rightItems.length >= 3 && scale.leftItems.length == 1);
        expect(pileVsSingle, isFalse, reason: puzzle.identityKey);
        final shared = scale.leftItems.toSet().intersection(
          scale.rightItems.toSet(),
        );
        expect(
          shared,
          isEmpty,
          reason: 'cancel shortcut pans: ${puzzle.identityKey}',
        );
      }
      expect(
        BalancePuzzle.uniqueHeaviestImpliedBy(puzzle.choices, puzzle.scales),
        puzzle.correctObjectId,
        reason: puzzle.identityKey,
      );
      expect(
        _heavySideFrequencyUniquelyPicksAnswer(puzzle),
        isFalse,
        reason: 'frequency heuristic solved ${puzzle.identityKey}',
      );
    }
  });

  test('compound heavier-than-single without a unique max is ambiguous', () {
    const chocolate = 'assets/images/foods/Chocolate.png';
    const broccoli = 'assets/images/foods/Broccoli.png';
    const chicken = 'assets/images/foods/Drumstick.png';
    const coconut = 'assets/images/foods/Coconut.png';
    final scales = [
      const BalanceScaleComparison(
        leftItems: [broccoli, chicken],
        rightItems: [chocolate],
        leftWeight: 7,
        rightWeight: 6,
      ),
      const BalanceScaleComparison(
        leftItems: [coconut],
        rightItems: [chocolate],
        leftWeight: 2,
        rightWeight: 6,
      ),
    ];
    expect(
      BalancePuzzle.uniqueHeaviestImpliedBy(
        [chocolate, broccoli, chicken, coconut],
        scales,
      ),
      isNull,
    );
  });

  test('puzzles use only animals or only foods, never mixed', () {
    final seedRng = Random(55);
    var sawAnimals = false;
    var sawFoods = false;
    for (var i = 0; i < 60; i++) {
      final puzzle = BalancePuzzle.forCorrectCount(
        i % 12,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      _expectSingleObjectSet(puzzle);
      if (puzzle.objectSet == BalanceObjectSet.animals) {
        sawAnimals = true;
      } else {
        sawFoods = true;
      }
    }
    expect(sawAnimals, isTrue);
    expect(sawFoods, isTrue);
  });

  test('excluding avoids identical consecutive puzzles', () {
    final rng = Random(123);
    var previous = BalancePuzzle.forCorrectCount(0, random: rng);
    for (var i = 0; i < 20; i++) {
      final next = BalancePuzzle.forCorrectCount(
        0,
        random: rng,
        excluding: previous,
      );
      expect(next.identityKey, isNot(previous.identityKey));
      previous = next;
    }
  });
}

void _expectUniqueHeaviest(BalancePuzzle puzzle) {
  final maxWeight = puzzle.weightsByObject.values.reduce(
    (a, b) => a > b ? a : b,
  );
  final heaviest = puzzle.weightsByObject.entries
      .where((e) => e.value == maxWeight)
      .map((e) => e.key)
      .toList();
  expect(heaviest, hasLength(1));
  expect(puzzle.correctObjectId, heaviest.single);
}

void _expectScaleWeightsMatch(BalancePuzzle puzzle) {
  for (final scale in puzzle.scales) {
    expect(
      _sum(puzzle.weightsByObject, scale.leftItems),
      scale.leftWeight,
    );
    expect(
      _sum(puzzle.weightsByObject, scale.rightItems),
      scale.rightWeight,
    );
  }
}

int _sum(Map<String, int> weights, List<String> items) {
  return items.fold<int>(0, (total, id) => total + weights[id]!);
}

void _expectSingleItemPans(BalancePuzzle puzzle) {
  for (final scale in puzzle.scales) {
    expect(scale.leftItems, hasLength(1));
    expect(scale.rightItems, hasLength(1));
  }
}

void _expectSingleObjectSet(BalancePuzzle puzzle) {
  final expectedPrefix = switch (puzzle.objectSet) {
    BalanceObjectSet.animals => BalanceAssets.animalsPrefix,
    BalanceObjectSet.foods => BalanceAssets.foodsPrefix,
  };
  for (final choice in puzzle.choices) {
    expect(choice.startsWith(expectedPrefix), isTrue, reason: choice);
    expect(BalanceAssets.setForAsset(choice), puzzle.objectSet);
  }
  for (final scale in puzzle.scales) {
    for (final id in [...scale.leftItems, ...scale.rightItems]) {
      expect(id.startsWith(expectedPrefix), isTrue, reason: id);
    }
  }
}

/// True when one object uniquely appears most often on the heavy side of
/// unbalanced scales and that object is the correct answer.
bool _heavySideFrequencyUniquelyPicksAnswer(BalancePuzzle puzzle) {
  final counts = <String, int>{
    for (final id in puzzle.choices) id: 0,
  };
  for (final scale in puzzle.scales) {
    if (scale.isBalanced) {
      continue;
    }
    final heavierItems = scale.leftWeight > scale.rightWeight
        ? scale.leftItems
        : scale.rightItems;
    for (final id in heavierItems.toSet()) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
  }
  final maxCount = counts.values.reduce((a, b) => a > b ? a : b);
  if (maxCount == 0) {
    return false;
  }
  final tops = counts.entries
      .where((e) => e.value == maxCount)
      .map((e) => e.key)
      .toList();
  return tops.length == 1 && tops.single == puzzle.correctObjectId;
}
