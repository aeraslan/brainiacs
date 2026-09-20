import 'dart:math';

import 'package:flutter/material.dart';

import 'stroop_palette.dart';

enum StroopRule { matchColor, matchText }

enum ColorClashLevel { one, two, three }

/// One answer option. For levels 1–2 [paintColorId] equals [identityId]
/// (solid swatch). For level 3 the label names [identityId] but is painted
/// with a mismatched [paintColorId].
class StroopChoice {
  const StroopChoice({
    required this.identityId,
    required this.paintColorId,
  });

  final String identityId;
  final String paintColorId;

  String get label => StroopPalette.byId(identityId).name;

  Color get paintColor => StroopPalette.byId(paintColorId).color;

  bool get isMismatched => identityId != paintColorId;

  String get identityKey => '$identityId:$paintColorId';
}

/// A single Color Clash (Stroop) round.
class ColorClashRound {
  const ColorClashRound({
    required this.level,
    required this.rule,
    required this.targetWordId,
    required this.targetPaintId,
    required this.choices,
    required this.correctIdentityId,
  });

  final ColorClashLevel level;
  final StroopRule rule;
  final String targetWordId;
  final String targetPaintId;
  final List<StroopChoice> choices;
  final String correctIdentityId;

  String get targetWord => StroopPalette.byId(targetWordId).name;

  Color get targetColor => StroopPalette.byId(targetPaintId).color;

  bool get usesTextOptions => level == ColorClashLevel.three;

  String get identityKey {
    final choiceKeys = choices.map((c) => c.identityKey).join(',');
    return '$level|$rule|$targetWordId|$targetPaintId|$correctIdentityId|$choiceKeys';
  }

  bool isCorrect(String optionIdentityId) =>
      optionIdentityId == correctIdentityId;

  static ColorClashLevel levelForCorrectCount(int correctCount) {
    if (correctCount >= 10) {
      return ColorClashLevel.three;
    }
    if (correctCount >= 5) {
      return ColorClashLevel.two;
    }
    return ColorClashLevel.one;
  }

  /// Demo beats so the tutorial shows every level and both rules quickly.
  static const List<(ColorClashLevel, StroopRule)> tutorialBeats = [
    (ColorClashLevel.one, StroopRule.matchColor),
    (ColorClashLevel.two, StroopRule.matchText),
    (ColorClashLevel.three, StroopRule.matchColor),
    (ColorClashLevel.three, StroopRule.matchText),
  ];

  factory ColorClashRound.forCorrectCount(
    int correctCount, {
    Random? random,
    ColorClashRound? excluding,
    StroopRule? forceRule,
  }) {
    final rng = random ?? Random();
    final level = levelForCorrectCount(correctCount);

    for (var attempt = 0; attempt < 64; attempt++) {
      final candidate = _generate(
        level: level,
        random: rng,
        forceRule: forceRule,
      );
      if (excluding == null || candidate.identityKey != excluding.identityKey) {
        return candidate;
      }
    }

    return _generate(level: level, random: rng, forceRule: forceRule);
  }

  /// Tutorial generator: forced [rule] at a specific [level].
  factory ColorClashRound.forTutorial({
    required ColorClashLevel level,
    required StroopRule rule,
    Random? random,
    ColorClashRound? excluding,
  }) {
    final correctCount = switch (level) {
      ColorClashLevel.one => 0,
      ColorClashLevel.two => 5,
      ColorClashLevel.three => 10,
    };
    return ColorClashRound.forCorrectCount(
      correctCount,
      random: random,
      excluding: excluding,
      forceRule: rule,
    );
  }

  factory ColorClashRound.forTutorialBeat(
    int beat, {
    Random? random,
    ColorClashRound? excluding,
  }) {
    final spec = tutorialBeats[beat % tutorialBeats.length];
    return ColorClashRound.forTutorial(
      level: spec.$1,
      rule: spec.$2,
      random: random,
      excluding: excluding,
    );
  }

  static ColorClashRound _generate({
    required ColorClashLevel level,
    required Random random,
    StroopRule? forceRule,
  }) {
    final palette = List<StroopColor>.from(StroopPalette.all)..shuffle(random);

    final word = palette[0];
    final paint = palette[1];

    final rule = forceRule ??
        switch (level) {
          ColorClashLevel.one => StroopRule.matchColor,
          ColorClashLevel.two || ColorClashLevel.three =>
            random.nextBool() ? StroopRule.matchColor : StroopRule.matchText,
        };

    final correctId = rule == StroopRule.matchColor ? paint.id : word.id;
    final lureId = rule == StroopRule.matchColor ? word.id : paint.id;

    final remaining = palette
        .where((c) => c.id != correctId && c.id != lureId)
        .toList();
    remaining.shuffle(random);

    final optionIds = <String>[correctId, lureId, remaining[0].id, remaining[1].id]
      ..shuffle(random);

    final choices = <StroopChoice>[
      for (final id in optionIds)
        StroopChoice(
          identityId: id,
          paintColorId: level == ColorClashLevel.three
              ? _mismatchedPaintId(
                  identityId: id,
                  palette: palette,
                  random: random,
                )
              : id,
        ),
    ];

    return ColorClashRound(
      level: level,
      rule: rule,
      targetWordId: word.id,
      targetPaintId: paint.id,
      choices: List<StroopChoice>.unmodifiable(choices),
      correctIdentityId: correctId,
    );
  }

  static String _mismatchedPaintId({
    required String identityId,
    required List<StroopColor> palette,
    required Random random,
  }) {
    final others = palette.where((c) => c.id != identityId).toList();
    return others[random.nextInt(others.length)].id;
  }
}
