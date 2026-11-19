import 'package:brainiacs_flutter/features/statistics/domain/performance_chart_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('yMaxFor', () {
    test('returns a readable upper bound with headroom for 7010', () {
      expect(PerformanceChartScale.yMaxFor(7010), 8000);
    });

    test('keeps zero / negative scores at a small readable ceiling', () {
      expect(PerformanceChartScale.yMaxFor(0), 100);
      expect(PerformanceChartScale.yMaxFor(-10), 100);
    });

    test('does not clip the highest visible score', () {
      expect(PerformanceChartScale.yMaxFor(8000), greaterThanOrEqualTo(8000));
      expect(PerformanceChartScale.yMaxFor(15000), greaterThanOrEqualTo(15000));
      expect(PerformanceChartScale.yMaxFor(1), greaterThanOrEqualTo(1));
    });

    test('handles tiny and mid-range scores', () {
      expect(PerformanceChartScale.yMaxFor(50), 60);
      expect(PerformanceChartScale.yMaxFor(3450), 4000);
    });
  });

  group('yTicks', () {
    test('produces round ticks for an 8000 ceiling', () {
      expect(
        PerformanceChartScale.yTicks(8000),
        [0, 2000, 4000, 6000, 8000],
      );
    });

    test('always starts at zero and ends at yMax', () {
      for (final max in [100, 500, 1000, 2500, 10000]) {
        final ticks = PerformanceChartScale.yTicks(max);
        expect(ticks.first, 0);
        expect(ticks.last, max);
        expect(ticks.length, inInclusiveRange(3, 7));
        for (var i = 1; i < ticks.length; i++) {
          expect(ticks[i], greaterThan(ticks[i - 1]));
        }
      }
    });
  });

  group('visibleXLabelIndices', () {
    test('shows every run when count is small', () {
      expect(PerformanceChartScale.visibleXLabelIndices(1), [0]);
      expect(PerformanceChartScale.visibleXLabelIndices(2), [0, 1]);
      expect(PerformanceChartScale.visibleXLabelIndices(5), [0, 1, 2, 3, 4]);
    });

    test('thins labels for denser windows while keeping ends', () {
      final indices = PerformanceChartScale.visibleXLabelIndices(10);
      expect(indices.first, 0);
      expect(indices.last, 9);
      expect(indices.length, lessThanOrEqualTo(5));
      expect(indices, orderedEquals([...indices]..sort()));
    });

    test('returns empty for zero sessions', () {
      expect(PerformanceChartScale.visibleXLabelIndices(0), isEmpty);
    });
  });
}
