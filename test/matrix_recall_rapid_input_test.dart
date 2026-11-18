import 'package:brainiacs_flutter/features/memory/presentation/matrix_recall_notifier.dart';
import 'package:brainiacs_flutter/features/memory/presentation/widgets/candy_memory_tile.dart';
import 'package:brainiacs_flutter/features/memory/presentation/widgets/matrix_recall_board.dart';
import 'package:brainiacs_flutter/shared/widgets/press_down_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _disposeAnimateTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  group('MatrixRecallBoard press-down', () {
    testWidgets('rapid downs on separate tiles each register', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 320,
              child: MatrixRecallBoard(
                gridSize: 3,
                litTileIndex: null,
                wrongTileIndex: null,
                inputUnlocked: true,
                onTileTapped: taps.add,
              ),
            ),
          ),
        ),
      );

      final detectors = find.byType(PressDownDetector);
      expect(detectors, findsNWidgets(9));

      final firstCenter = tester.getCenter(detectors.at(0));
      final secondCenter = tester.getCenter(detectors.at(1));
      final thirdCenter = tester.getCenter(detectors.at(2));

      final g1 = await tester.startGesture(firstCenter);
      await tester.pump();
      final g2 = await tester.startGesture(secondCenter);
      await tester.pump();
      final g3 = await tester.startGesture(thirdCenter);
      await tester.pump();

      expect(taps, [0, 1, 2]);

      await g1.up();
      await g2.up();
      await g3.up();
      await tester.pump();
      expect(taps, [0, 1, 2]);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('disabled tiles ignore pointer down', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 320,
              child: MatrixRecallBoard(
                gridSize: 3,
                litTileIndex: null,
                wrongTileIndex: null,
                inputUnlocked: false,
                onTileTapped: taps.add,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CandyMemoryTile).first);
      await tester.pump();
      expect(taps, isEmpty);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('release outside the original cell still counts', (
      tester,
    ) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 320,
              child: MatrixRecallBoard(
                gridSize: 3,
                litTileIndex: null,
                wrongTileIndex: null,
                inputUnlocked: true,
                onTileTapped: taps.add,
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(PressDownDetector).at(4));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(taps, [4]);

      await gesture.moveBy(const Offset(300, 300));
      await gesture.up();
      await tester.pump();
      expect(taps, [4]);
      await _disposeAnimateTimers(tester);
    });
  });

  group('MatrixRecallState.inputUnlocked', () {
    test('locks during watch, evaluation, and wrong feedback', () {
      const playReady = MatrixRecallState(
        phase: MatrixRecallPhase.play,
        sequence: [0, 1, 2],
        currentSequenceIndex: 0,
        sequenceLength: 3,
        gridSize: 3,
      );
      expect(playReady.inputUnlocked, isTrue);

      const watching = MatrixRecallState(
        phase: MatrixRecallPhase.watch,
        sequence: [0, 1, 2],
        currentSequenceIndex: 0,
        sequenceLength: 3,
        gridSize: 3,
      );
      expect(watching.inputUnlocked, isFalse);

      const evaluating = MatrixRecallState(
        phase: MatrixRecallPhase.play,
        sequence: [0, 1, 2],
        currentSequenceIndex: 3,
        sequenceLength: 3,
        gridSize: 3,
        isEvaluating: true,
      );
      expect(evaluating.inputUnlocked, isFalse);

      const wrongFeedback = MatrixRecallState(
        phase: MatrixRecallPhase.play,
        sequence: [0, 1, 2],
        currentSequenceIndex: 0,
        sequenceLength: 3,
        gridSize: 3,
        wrongTileIndex: 4,
      );
      expect(wrongFeedback.inputUnlocked, isFalse);
    });
  });
}
