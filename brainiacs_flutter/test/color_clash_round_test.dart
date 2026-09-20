import 'dart:math';

import 'package:brainiacs_flutter/features/visual/domain/color_clash_round.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('levels map from correctCount', () {
    expect(ColorClashRound.levelForCorrectCount(0), ColorClashLevel.one);
    expect(ColorClashRound.levelForCorrectCount(4), ColorClashLevel.one);
    expect(ColorClashRound.levelForCorrectCount(5), ColorClashLevel.two);
    expect(ColorClashRound.levelForCorrectCount(9), ColorClashLevel.two);
    expect(ColorClashRound.levelForCorrectCount(10), ColorClashLevel.three);
    expect(ColorClashRound.levelForCorrectCount(40), ColorClashLevel.three);
  });

  test('level 1 always matchColor with solid swatches', () {
    final seedRng = Random(42);
    for (var i = 0; i < 40; i++) {
      final round = ColorClashRound.forCorrectCount(
        0,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(round.level, ColorClashLevel.one);
      expect(round.rule, StroopRule.matchColor);
      expect(round.usesTextOptions, isFalse);
      _expectCoreInvariants(round);
      for (final choice in round.choices) {
        expect(choice.isMismatched, isFalse);
      }
    }
  });

  test('level 2 toggles rules and keeps solid swatches', () {
    final seedRng = Random(99);
    var sawMatchColor = false;
    var sawMatchText = false;

    for (var i = 0; i < 60; i++) {
      final round = ColorClashRound.forCorrectCount(
        5,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(round.level, ColorClashLevel.two);
      expect(round.usesTextOptions, isFalse);
      _expectCoreInvariants(round);
      for (final choice in round.choices) {
        expect(choice.isMismatched, isFalse);
      }
      if (round.rule == StroopRule.matchColor) {
        sawMatchColor = true;
      } else {
        sawMatchText = true;
      }
    }

    expect(sawMatchColor, isTrue);
    expect(sawMatchText, isTrue);
  });

  test('level 3 double stroop mismatches every option paint', () {
    final seedRng = Random(7);
    var sawMatchColor = false;
    var sawMatchText = false;

    for (var i = 0; i < 60; i++) {
      final round = ColorClashRound.forCorrectCount(
        10,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(round.level, ColorClashLevel.three);
      expect(round.usesTextOptions, isTrue);
      _expectCoreInvariants(round);
      for (final choice in round.choices) {
        expect(choice.isMismatched, isTrue);
        expect(choice.label, isNotEmpty);
      }
      if (round.rule == StroopRule.matchColor) {
        sawMatchColor = true;
      } else {
        sawMatchText = true;
      }
    }

    expect(sawMatchColor, isTrue);
    expect(sawMatchText, isTrue);
  });

  test('isCorrect follows active rule', () {
    final matchColor = ColorClashRound.forCorrectCount(0, random: Random(1));
    expect(matchColor.rule, StroopRule.matchColor);
    expect(matchColor.isCorrect(matchColor.targetPaintId), isTrue);
    expect(matchColor.isCorrect(matchColor.targetWordId), isFalse);

    ColorClashRound? matchText;
    final seedRng = Random(3);
    for (var i = 0; i < 80; i++) {
      final candidate = ColorClashRound.forCorrectCount(
        5,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      if (candidate.rule == StroopRule.matchText) {
        matchText = candidate;
        break;
      }
    }
    expect(matchText, isNotNull);
    expect(matchText!.isCorrect(matchText.targetWordId), isTrue);
    expect(matchText.isCorrect(matchText.targetPaintId), isFalse);
  });

  test('excluding regenerates a different identity', () {
    final first = ColorClashRound.forCorrectCount(0, random: Random(11));
    final second = ColorClashRound.forCorrectCount(
      0,
      random: Random(11),
      excluding: first,
    );
    expect(second.identityKey, isNot(first.identityKey));
  });

  test('tutorial beats cover all three levels and both rules', () {
    expect(ColorClashRound.tutorialBeats, hasLength(4));
    expect(ColorClashRound.tutorialBeats[0], (
      ColorClashLevel.one,
      StroopRule.matchColor,
    ));
    expect(ColorClashRound.tutorialBeats[1], (
      ColorClashLevel.two,
      StroopRule.matchText,
    ));
    expect(ColorClashRound.tutorialBeats[2], (
      ColorClashLevel.three,
      StroopRule.matchColor,
    ));
    expect(ColorClashRound.tutorialBeats[3], (
      ColorClashLevel.three,
      StroopRule.matchText,
    ));

    final seedRng = Random(21);
    for (var beat = 0; beat < ColorClashRound.tutorialBeats.length; beat++) {
      final expected = ColorClashRound.tutorialBeats[beat];
      final round = ColorClashRound.forTutorialBeat(
        beat,
        random: Random(seedRng.nextInt(1 << 30)),
      );
      expect(round.level, expected.$1);
      expect(round.rule, expected.$2);
      expect(round.usesTextOptions, expected.$1 == ColorClashLevel.three);
      _expectCoreInvariants(round);
      if (round.level == ColorClashLevel.three) {
        for (final choice in round.choices) {
          expect(choice.isMismatched, isTrue);
        }
      } else {
        for (final choice in round.choices) {
          expect(choice.isMismatched, isFalse);
        }
      }
    }
  });
}

void _expectCoreInvariants(ColorClashRound round) {
  expect(round.targetWordId, isNot(round.targetPaintId));
  expect(round.choices, hasLength(4));
  expect(
    round.choices.map((c) => c.identityId).toSet(),
    hasLength(4),
  );
  expect(
    round.choices.map((c) => c.identityId),
    contains(round.correctIdentityId),
  );

  final lureId = round.rule == StroopRule.matchColor
      ? round.targetWordId
      : round.targetPaintId;
  expect(
    round.choices.map((c) => c.identityId),
    contains(lureId),
  );

  final expectedCorrect = round.rule == StroopRule.matchColor
      ? round.targetPaintId
      : round.targetWordId;
  expect(round.correctIdentityId, expectedCorrect);
}
