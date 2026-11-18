import 'dart:math' as math;

/// Axis scaling helpers for the Recent Performance chart.
abstract final class PerformanceChartScale {
  /// Soft headroom above the highest visible score before rounding.
  static const double headroomFactor = 1.12;

  /// Preferred number of Y-axis ticks including 0 and the upper bound.
  static const int preferredYTickCount = 5;

  /// Maximum X-axis labels shown when the window is dense.
  static const int maxXLabels = 5;

  /// Computes a rounded Y-axis upper bound for [maxScore], always ≥ 0.
  ///
  /// Starts at zero, adds a little headroom, then snaps up to a human-readable
  /// magnitude (e.g. 7,010 → 8,000).
  static int yMaxFor(int maxScore) {
    if (maxScore <= 0) {
      return 100;
    }

    final padded = (maxScore * headroomFactor).ceil();
    if (padded <= 10) {
      return 10;
    }

    final exp = (math.log(padded) / math.ln10).floor();
    final magnitude = math.pow(10, exp).toInt();
    final normalized = padded / magnitude;

    const steps = <double>[1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10];
    for (final step in steps) {
      if (normalized <= step) {
        return (step * magnitude).round();
      }
    }
    return 10 * magnitude;
  }

  /// Evenly spaced Y-axis tick values from 0 to [yMax], inclusive.
  ///
  /// Chooses a step that divides [yMax] cleanly when possible so labels stay
  /// round (e.g. 0 / 2,000 / 4,000 / 6,000 / 8,000).
  static List<int> yTicks(int yMax) {
    final safeMax = yMax <= 0 ? 100 : yMax;
    final step = _preferredStep(safeMax, preferredYTickCount - 1);
    final ticks = <int>[0];
    var value = step;
    while (value < safeMax) {
      ticks.add(value);
      value += step;
    }
    if (ticks.last != safeMax) {
      ticks.add(safeMax);
    }
    return ticks;
  }

  /// Indices into the recent-session window that should show an X label.
  ///
  /// For ≤ [maxXLabels] sessions every index is shown. For denser windows the
  /// first, last, and evenly spaced middles are kept.
  static List<int> visibleXLabelIndices(int sessionCount) {
    if (sessionCount <= 0) {
      return const [];
    }
    if (sessionCount <= maxXLabels) {
      return List<int>.generate(sessionCount, (i) => i);
    }

    final indices = <int>{0, sessionCount - 1};
    for (var i = 1; i < maxXLabels - 1; i++) {
      final index =
          ((sessionCount - 1) * i / (maxXLabels - 1)).round().clamp(
                0,
                sessionCount - 1,
              );
      indices.add(index);
    }
    return indices.toList()..sort();
  }

  /// 1-based run label for a position in the displayed window.
  static String runLabel(int zeroBasedIndex) => 'Run ${zeroBasedIndex + 1}';

  static int _preferredStep(int yMax, int divisions) {
    if (divisions <= 0) {
      return yMax;
    }

    final raw = yMax / divisions;
    final exp = (math.log(raw) / math.ln10).floor();
    final magnitude = math.pow(10, exp).toDouble();
    final normalized = raw / magnitude;

    final nice = normalized <= 1
        ? 1.0
        : normalized <= 2
            ? 2.0
            : normalized <= 2.5
                ? 2.5
                : normalized <= 5
                    ? 5.0
                    : 10.0;

    var step = (nice * magnitude).round();
    if (step <= 0) {
      step = 1;
    }

    // Prefer a step that lands exactly on yMax when feasible.
    if (yMax % step == 0) {
      return step;
    }
    for (final candidate in [
      (1 * magnitude).round(),
      (2 * magnitude).round(),
      (2.5 * magnitude).round(),
      (5 * magnitude).round(),
      (10 * magnitude).round(),
    ]) {
      if (candidate > 0 && yMax % candidate == 0) {
        final tickCount = yMax ~/ candidate;
        if (tickCount >= 2 && tickCount <= 6) {
          return candidate;
        }
      }
    }
    return step;
  }
}
