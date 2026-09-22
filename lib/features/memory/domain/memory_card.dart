import 'dart:math';
import 'dart:ui';

import '../../analytical/domain/balance_assets.dart';

class MemoryCard {
  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.assetPath,
    required this.isFaceUp,
    required this.isMatched,
    required this.rotationRadians,
    required this.offset,
  });

  final int id;
  final int pairId;
  final String assetPath;
  final bool isFaceUp;
  final bool isMatched;
  final double rotationRadians;
  final Offset offset;

  MemoryCard copyWith({
    int? id,
    int? pairId,
    String? assetPath,
    bool? isFaceUp,
    bool? isMatched,
    double? rotationRadians,
    Offset? offset,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      assetPath: assetPath ?? this.assetPath,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
      rotationRadians: rotationRadians ?? this.rotationRadians,
      offset: offset ?? this.offset,
    );
  }
}

abstract final class MemoryCardDeck {
  /// Combined animal + food stickers used for Card Match pairs.
  static const List<String> imagePool = [
    ...BalanceAssets.animals,
    ...BalanceAssets.foods,
  ];

  static const double minRotationRadians = -0.262;
  static const double maxRotationRadians = 0.262;
  static const double maxOffset = 6;

  static List<MemoryCard> deal({
    required int pairCount,
    Random? random,
  }) {
    final rng = random ?? Random();
    final safePairCount = pairCount.clamp(1, imagePool.length);
    final selectedPaths = List<String>.from(imagePool)..shuffle(rng);

    final cards = <MemoryCard>[];
    var id = 0;

    for (var pairId = 0; pairId < safePairCount; pairId++) {
      final assetPath = selectedPaths[pairId];
      for (var copy = 0; copy < 2; copy++) {
        cards.add(
          MemoryCard(
            id: id,
            pairId: pairId,
            assetPath: assetPath,
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
