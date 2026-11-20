import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TitleTier.fromScore', () {
    test('maps boundary scores to the correct tiers', () {
      expect(TitleTier.fromScore(0), TitleTier.dormantMind);
      expect(TitleTier.fromScore(1499), TitleTier.dormantMind);
      expect(TitleTier.fromScore(1500), TitleTier.mindApprentice);
      expect(TitleTier.fromScore(2999), TitleTier.mindApprentice);
      expect(TitleTier.fromScore(3000), TitleTier.activeNeuron);
      expect(TitleTier.fromScore(4499), TitleTier.activeNeuron);
      expect(TitleTier.fromScore(4500), TitleTier.sharpIntellect);
      expect(TitleTier.fromScore(5999), TitleTier.sharpIntellect);
      expect(TitleTier.fromScore(6000), TitleTier.analyticMind);
      expect(TitleTier.fromScore(7499), TitleTier.analyticMind);
      expect(TitleTier.fromScore(7500), TitleTier.quantumBrain);
      expect(TitleTier.fromScore(8999), TitleTier.quantumBrain);
      expect(TitleTier.fromScore(9000), TitleTier.synapseLord);
      expect(TitleTier.fromScore(10499), TitleTier.synapseLord);
      expect(TitleTier.fromScore(10500), TitleTier.brainiac);
      expect(TitleTier.fromScore(20000), TitleTier.brainiac);
    });

    test('clamps negative scores to Dormant Mind', () {
      expect(TitleTier.fromScore(-50), TitleTier.dormantMind);
    });
  });

  group('TitleTier.nextLower', () {
    test('drops one tier and floors at Dormant Mind', () {
      expect(TitleTier.brainiac.nextLower, TitleTier.synapseLord);
      expect(TitleTier.mindApprentice.nextLower, TitleTier.dormantMind);
      expect(TitleTier.dormantMind.nextLower, TitleTier.dormantMind);
    });
  });

  group('TitleTier.tryParse', () {
    test('round-trips enum names', () {
      for (final tier in TitleTier.values) {
        expect(TitleTier.tryParse(tier.name), tier);
      }
      expect(TitleTier.tryParse(null), isNull);
      expect(TitleTier.tryParse(''), isNull);
      expect(TitleTier.tryParse('notATier'), isNull);
    });
  });

  group('TitleTier ladder helpers', () {
    test('rankNumber is 1-based and matches enum order', () {
      expect(TitleTier.count, 8);
      expect(TitleTier.dormantMind.rankNumber, 1);
      expect(TitleTier.activeNeuron.rankNumber, 3);
      expect(TitleTier.brainiac.rankNumber, 8);
      for (var i = 0; i < TitleTier.values.length; i++) {
        expect(TitleTier.values[i].rankNumber, i + 1);
      }
    });

    test('nextHigher climbs and returns null at the top', () {
      expect(TitleTier.dormantMind.nextHigher, TitleTier.mindApprentice);
      expect(TitleTier.synapseLord.nextHigher, TitleTier.brainiac);
      expect(TitleTier.brainiac.nextHigher, isNull);
      expect(TitleTier.brainiac.isHighest, isTrue);
      expect(TitleTier.dormantMind.isHighest, isFalse);
    });

    test('progressToNext uses run score against configured thresholds', () {
      expect(TitleTier.dormantMind.progressToNext(0), 0);
      expect(TitleTier.dormantMind.progressToNext(750), 0.5);
      expect(TitleTier.dormantMind.progressToNext(1500), 1);
      expect(TitleTier.dormantMind.progressToNext(5000), 1);

      expect(TitleTier.activeNeuron.progressToNext(3000), 0);
      expect(TitleTier.activeNeuron.progressToNext(3750), 0.5);
      expect(TitleTier.activeNeuron.progressToNext(4500), 1);

      expect(TitleTier.synapseLord.progressToNext(9000), 0);
      expect(TitleTier.synapseLord.progressToNext(9750), 0.5);
      expect(TitleTier.synapseLord.progressToNext(10499), closeTo(0.999, 0.01));
      expect(TitleTier.synapseLord.progressToNext(10500), 1);

      expect(TitleTier.brainiac.progressToNext(0), 1);
      expect(TitleTier.brainiac.progressToNext(20000), 1);
    });

    test('configured minScore thresholds match the rebalanced ladder', () {
      expect(TitleTier.dormantMind.minScore, 0);
      expect(TitleTier.mindApprentice.minScore, 1500);
      expect(TitleTier.activeNeuron.minScore, 3000);
      expect(TitleTier.sharpIntellect.minScore, 4500);
      expect(TitleTier.analyticMind.minScore, 6000);
      expect(TitleTier.quantumBrain.minScore, 7500);
      expect(TitleTier.synapseLord.minScore, 9000);
      expect(TitleTier.brainiac.minScore, 10500);
    });
  });
}
