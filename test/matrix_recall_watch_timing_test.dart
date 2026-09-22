import 'package:brainiacs_flutter/features/memory/presentation/matrix_recall_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatrixRecallState.watchDurationsFor', () {
    test('length 3 uses baseline lit and gap', () {
      final timings = MatrixRecallState.watchDurationsFor(3);
      expect(timings.lit, MatrixRecallState.tileLitDuration);
      expect(timings.gap, MatrixRecallState.tileGapDuration);
    });

    test('length below baseline stays at base timings', () {
      final timings = MatrixRecallState.watchDurationsFor(1);
      expect(timings.lit, const Duration(milliseconds: 600));
      expect(timings.gap, const Duration(milliseconds: 200));
    });

    test('length 4 reduces lit by 80ms and gap by 25ms', () {
      final timings = MatrixRecallState.watchDurationsFor(4);
      expect(timings.lit, const Duration(milliseconds: 520));
      expect(timings.gap, const Duration(milliseconds: 175));
    });

    test('very long sequences clamp to min lit and gap floors', () {
      final timings = MatrixRecallState.watchDurationsFor(20);
      expect(timings.lit, const Duration(milliseconds: 250));
      expect(timings.gap, const Duration(milliseconds: 80));
    });
  });
}
