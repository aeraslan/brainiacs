import 'dart:math';

import 'package:flutter/material.dart';

class MemoryCard {
  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.icon,
    required this.isFaceUp,
    required this.isMatched,
    required this.rotationRadians,
    required this.offset,
  });

  final int id;
  final int pairId;
  final IconData icon;
  final bool isFaceUp;
  final bool isMatched;
  final double rotationRadians;
  final Offset offset;

  MemoryCard copyWith({
    int? id,
    int? pairId,
    IconData? icon,
    bool? isFaceUp,
    bool? isMatched,
    double? rotationRadians,
    Offset? offset,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      icon: icon ?? this.icon,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
      rotationRadians: rotationRadians ?? this.rotationRadians,
      offset: offset ?? this.offset,
    );
  }
}

abstract final class MemoryCardDeck {
  static const List<IconData> iconPool = [
    Icons.star_rounded,
    Icons.circle,
    Icons.change_history_rounded,
    Icons.diamond_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
    Icons.nightlight_rounded,
    Icons.wb_sunny_rounded,
  ];

  static const double minRotationRadians = -0.262;
  static const double maxRotationRadians = 0.262;
  static const double maxOffset = 6;

  static List<MemoryCard> deal({
    required int pairCount,
    Random? random,
  }) {
    final rng = random ?? Random();
    final safePairCount = pairCount.clamp(1, iconPool.length);
    final selectedIcons = List<IconData>.from(iconPool)..shuffle(rng);

    final cards = <MemoryCard>[];
    var id = 0;

    for (var pairId = 0; pairId < safePairCount; pairId++) {
      final icon = selectedIcons[pairId];
      for (var copy = 0; copy < 2; copy++) {
        cards.add(
          MemoryCard(
            id: id,
            pairId: pairId,
            icon: icon,
            isFaceUp: false,
            isMatched: false,
            rotationRadians: _randomRotation(rng),
            offset: _randomOffset(rng),
          ),
        );
        id++;
      }
    }

    cards.shuffle(rng);
    return cards;
  }

  static double _randomRotation(Random rng) {
    return minRotationRadians +
        rng.nextDouble() * (maxRotationRadians - minRotationRadians);
  }

  static Offset _randomOffset(Random rng) {
    return Offset(
      (rng.nextDouble() * 2 - 1) * maxOffset,
      (rng.nextDouble() * 2 - 1) * maxOffset,
    );
  }
}
