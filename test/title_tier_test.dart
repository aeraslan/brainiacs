import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TitleTier.fromScore', () {
    test('maps boundary scores to the correct tiers', () {
      expect(TitleTier.fromScore(0), TitleTier.dormantMind);
      expect(TitleTier.fromScore(1999), TitleTier.dormantMind);
      expect(TitleTier.fromScore(2000), TitleTier.mindApprentice);
      expect(TitleTier.fromScore(4499), TitleTier.mindApprentice);
      expect(TitleTier.fromScore(4500), TitleTier.activeNeuron);
      expect(TitleTier.fromScore(6499), TitleTier.activeNeuron);
      expect(TitleTier.fromScore(6500), TitleTier.sharpIntellect);
      expect(TitleTier.fromScore(8499), TitleTier.sharpIntellect);
      expect(TitleTier.fromScore(8500), TitleTier.analyticMind);
      expect(TitleTier.fromScore(10499), TitleTier.analyticMind);
      expect(TitleTier.fromScore(10500), TitleTier.quantumBrain);
      expect(TitleTier.fromScore(12499), TitleTier.quantumBrain);
      expect(TitleTier.fromScore(12500), TitleTier.synapseLord);
      expect(TitleTier.fromScore(14999), TitleTier.synapseLord);
      expect(TitleTier.fromScore(15000), TitleTier.brainiac);
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
}
