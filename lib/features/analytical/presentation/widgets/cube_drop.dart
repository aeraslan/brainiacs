import 'dart:math' as math;

import 'package:flutter/animation.dart';

import '../../domain/cube_puzzle.dart';

/// Timing and offsets for the Cube Count cascading fall-in intro.
class CubeDrop {
  CubeDrop._();

  /// How long one cube takes to fall once it starts.
  static const Duration layerDropDuration = Duration(milliseconds: 280);

  /// Delay before the next layer's first cube starts (overlaps prior layer).
  static const Duration layerCascadeDelay = Duration(milliseconds: 85);

  /// Small delay between cubes that share the same layer.
  static const Duration cubeStaggerDelay = Duration(milliseconds: 16);

  /// How far above rest a cube starts, as a multiple of isometric [rise].
  static const double fallDistanceRiseFactor = 2.5;

  /// Slight bounce past rest before settling (fraction of [fallDistance]).
  static const double overshootFraction = 0.06;

  static const Curve dropCurve = Curves.easeOutCubic;

  /// Latest finish time among cubes described by [maxHeight] and per-layer
  /// occupancy. [maxCubesInLayer] should be the densest layer's cube count
  /// (used as a safe upper bound when the last layer is unknown).
  static Duration durationFor({
    required int maxHeight,
    required int maxCubesInLayer,
  }) {
    if (maxHeight <= 0) {
      return Duration.zero;
    }
    final cascadeMs = layerCascadeDelay.inMilliseconds;
    final staggerMs = cubeStaggerDelay.inMilliseconds;
    final dropMs = layerDropDuration.inMilliseconds;
    final cubes = maxCubesInLayer.clamp(1, 99);
    final lastStartMs =
        (maxHeight - 1) * cascadeMs + (cubes - 1) * staggerMs;
    return Duration(milliseconds: lastStartMs + dropMs);
  }

  /// Convenience for a [CubePuzzle]: duration covers every present cube.
  static Duration durationForPuzzle(CubePuzzle puzzle) {
    var maxHeight = 0;
    final perLayer = <int, int>{};
    for (final row in puzzle.heights) {
      for (final h in row) {
        if (h > maxHeight) {
          maxHeight = h;
        }
        for (var z = 0; z < h; z++) {
          perLayer[z] = (perLayer[z] ?? 0) + 1;
        }
      }
    }
    if (maxHeight <= 0) {
      return Duration.zero;
    }

    final cascadeMs = layerCascadeDelay.inMilliseconds;
    final staggerMs = cubeStaggerDelay.inMilliseconds;
    final dropMs = layerDropDuration.inMilliseconds;
    var lastFinish = 0;
    for (var layer = 0; layer < maxHeight; layer++) {
      final count = perLayer[layer] ?? 0;
      if (count <= 0) {
        continue;
      }
      final start = layer * cascadeMs + (count - 1) * staggerMs;
      lastFinish = math.max(lastFinish, start + dropMs);
    }
    return Duration(milliseconds: lastFinish);
  }

  /// Absolute start time (ms) for a cube within the cascade.
  static double startMs({
    required int layer,
    required int staggerIndex,
  }) {
    return (layer * layerCascadeDelay.inMilliseconds +
            staggerIndex * cubeStaggerDelay.inMilliseconds)
        .toDouble();
  }

  /// Progress within this cube's drop window, or null if not yet started.
  static double? localProgress({
    required int layer,
    required int staggerIndex,
    required double t,
    required int totalMs,
  }) {
    if (layer < 0 || staggerIndex < 0) {
      return null;
    }
    if (t >= 1.0) {
      return 1.0;
    }

    if (totalMs <= 0) {
      return 1.0;
    }

    final dropMs = layerDropDuration.inMilliseconds.toDouble();
    final start = startMs(layer: layer, staggerIndex: staggerIndex);
    final elapsedMs = t * totalMs;

    if (elapsedMs < start) {
      return null;
    }
    return ((elapsedMs - start) / dropMs).clamp(0.0, 1.0);
  }

  /// Screen-Y delta added to a cube's rest center.
  ///
  /// Starts at `-fallDistance` (above rest) and eases to `0` (landed).
  /// Returns `null` when the cube should not be drawn yet.
  static double? offsetY({
    required int layer,
    required int staggerIndex,
    required double t,
    required int totalMs,
    required double fallDistance,
  }) {
    final local = localProgress(
      layer: layer,
      staggerIndex: staggerIndex,
      t: t,
      totalMs: totalMs,
    );
    if (local == null) {
      return null;
    }
    if (local >= 1.0 || fallDistance <= 0) {
      return 0.0;
    }

    final eased = dropCurve.transform(local);
    var offset = -fallDistance * (1.0 - eased);

    if (local > 0.7) {
      final bounceLocal = (local - 0.7) / 0.3;
      offset += fallDistance *
          overshootFraction *
          math.sin(math.pi * bounceLocal);
    }
    return offset;
  }
}
