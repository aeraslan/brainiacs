import 'package:brainiacs_flutter/features/analytical/domain/cube_puzzle.dart';
import 'package:brainiacs_flutter/features/analytical/presentation/widgets/cube_drop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CubeDrop.durationFor', () {
    test('scales with overlapping layers and within-layer stagger', () {
      expect(
        CubeDrop.durationFor(maxHeight: 0, maxCubesInLayer: 1),
        Duration.zero,
      );
      expect(
        CubeDrop.durationFor(maxHeight: 1, maxCubesInLayer: 1),
        CubeDrop.layerDropDuration,
      );

      // Two layers, one cube each: second starts at cascade delay.
      expect(
        CubeDrop.durationFor(maxHeight: 2, maxCubesInLayer: 1),
        CubeDrop.layerCascadeDelay + CubeDrop.layerDropDuration,
      );

      // Same layer, three cubes: last starts after 2 staggers.
      expect(
        CubeDrop.durationFor(maxHeight: 1, maxCubesInLayer: 3),
        CubeDrop.cubeStaggerDelay * 2 + CubeDrop.layerDropDuration,
      );
    });
  });

  group('CubeDrop.durationForPuzzle', () {
    test('uses actual occupancy, not a dense-layer overestimate', () {
      const puzzle = CubePuzzle(
        heights: [
          [2, 0],
          [0, 1],
        ],
        expectedTotal: 3,
        level: 1,
      );
      // Layer 0 has 2 cubes, layer 1 has 1.
      // Last finish = max(
      //   layer0 last: 1*stagger + drop,
      //   layer1 first: cascade + drop,
      // )
      final stagger = CubeDrop.cubeStaggerDelay.inMilliseconds;
      final cascade = CubeDrop.layerCascadeDelay.inMilliseconds;
      final drop = CubeDrop.layerDropDuration.inMilliseconds;
      final expected = mathMax(stagger + drop, cascade + drop);
      expect(
        CubeDrop.durationForPuzzle(puzzle),
        Duration(milliseconds: expected),
      );
    });
  });

  group('CubeDrop.localProgress', () {
    test('layer 0 cube 0 starts immediately; later cubes stay hidden', () {
      final totalMs = CubeDrop.durationFor(
        maxHeight: 3,
        maxCubesInLayer: 2,
      ).inMilliseconds;

      expect(
        CubeDrop.localProgress(
          layer: 0,
          staggerIndex: 0,
          t: 0,
          totalMs: totalMs,
        ),
        0.0,
      );
      expect(
        CubeDrop.localProgress(
          layer: 0,
          staggerIndex: 1,
          t: 0,
          totalMs: totalMs,
        ),
        isNull,
      );
      expect(
        CubeDrop.localProgress(
          layer: 1,
          staggerIndex: 0,
          t: 0,
          totalMs: totalMs,
        ),
        isNull,
      );
    });

    test('next layer starts before previous layer finishes', () {
      final totalMs = CubeDrop.durationFor(
        maxHeight: 2,
        maxCubesInLayer: 1,
      ).inMilliseconds;
      final cascade = CubeDrop.layerCascadeDelay.inMilliseconds;
      final drop = CubeDrop.layerDropDuration.inMilliseconds;

      // At cascade delay, layer 0 is mid-flight and layer 1 just starts.
      final t = cascade / totalMs;
      final layer0 = CubeDrop.localProgress(
        layer: 0,
        staggerIndex: 0,
        t: t,
        totalMs: totalMs,
      )!;
      expect(layer0, greaterThan(0));
      expect(layer0, lessThan(1));
      expect(cascade < drop, isTrue);

      expect(
        CubeDrop.localProgress(
          layer: 1,
          staggerIndex: 0,
          t: t,
          totalMs: totalMs,
        ),
        closeTo(0.0, 0.02),
      );
    });

    test('same-layer cubes are staggered', () {
      final totalMs = CubeDrop.durationFor(
        maxHeight: 1,
        maxCubesInLayer: 3,
      ).inMilliseconds;
      final stagger = CubeDrop.cubeStaggerDelay.inMilliseconds;

      final t = stagger / totalMs;
      expect(
        CubeDrop.localProgress(
          layer: 0,
          staggerIndex: 0,
          t: t,
          totalMs: totalMs,
        ),
        greaterThan(0),
      );
      expect(
        CubeDrop.localProgress(
          layer: 0,
          staggerIndex: 1,
          t: t,
          totalMs: totalMs,
        ),
        closeTo(0.0, 0.02),
      );
      expect(
        CubeDrop.localProgress(
          layer: 0,
          staggerIndex: 2,
          t: t,
          totalMs: totalMs,
        ),
        isNull,
      );
    });

    test('t >= 1 lands every cube', () {
      for (var layer = 0; layer < 4; layer++) {
        for (var i = 0; i < 3; i++) {
          expect(
            CubeDrop.localProgress(
              layer: layer,
              staggerIndex: i,
              t: 1,
              totalMs: 1000,
            ),
            1.0,
          );
        }
      }
    });
  });

  group('CubeDrop.offsetY', () {
    const fall = 100.0;

    test('hidden cubes return null', () {
      final totalMs = CubeDrop.durationFor(
        maxHeight: 3,
        maxCubesInLayer: 1,
      ).inMilliseconds;
      expect(
        CubeDrop.offsetY(
          layer: 2,
          staggerIndex: 0,
          t: 0,
          totalMs: totalMs,
          fallDistance: fall,
        ),
        isNull,
      );
    });

    test('first cube starts above rest and settles to 0', () {
      final totalMs = CubeDrop.durationFor(
        maxHeight: 2,
        maxCubesInLayer: 1,
      ).inMilliseconds;

      expect(
        CubeDrop.offsetY(
          layer: 0,
          staggerIndex: 0,
          t: 0,
          totalMs: totalMs,
          fallDistance: fall,
        ),
        -fall,
      );

      final midT =
          (CubeDrop.layerDropDuration.inMilliseconds * 0.5) / totalMs;
      final mid = CubeDrop.offsetY(
        layer: 0,
        staggerIndex: 0,
        t: midT,
        totalMs: totalMs,
        fallDistance: fall,
      )!;
      expect(mid, greaterThan(-fall));
      expect(mid, lessThan(0));

      expect(
        CubeDrop.offsetY(
          layer: 0,
          staggerIndex: 0,
          t: 1,
          totalMs: totalMs,
          fallDistance: fall,
        ),
        0.0,
      );
    });
  });
}

int mathMax(int a, int b) => a > b ? a : b;
