import 'package:brainiacs_flutter/shared/widgets/candy_pad_button.dart';
import 'package:brainiacs_flutter/shared/widgets/press_down_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _disposeAnimateTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  group('PressDownDetector', () {
    testWidgets('fires once on pointer down', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressDownDetector(
                onPressed: () => count++,
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(PressDownDetector));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(count, 1);

      await gesture.up();
      await tester.pump();
      expect(count, 1);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('keeps the answer when finger slides outside then lifts', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressDownDetector(
                onPressed: () => count++,
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(PressDownDetector));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(count, 1);

      await gesture.moveBy(const Offset(200, 200));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(count, 1);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('ignores input when disabled', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressDownDetector(
                enabled: false,
                onPressed: () => count++,
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressDownDetector));
      await tester.pump();
      expect(count, 0);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('full tap produces exactly one callback', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressDownDetector(
                onPressed: () => count++,
                child: const SizedBox(
                  width: 80,
                  height: 80,
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressDownDetector));
      await tester.pump();
      expect(count, 1);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('second finger on same widget does not double-fire', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressDownDetector(
                onPressed: () => count++,
                child: const SizedBox(
                  width: 120,
                  height: 120,
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(PressDownDetector));
      final first = await tester.startGesture(center + const Offset(-20, 0));
      await tester.pump();
      expect(count, 1);

      final second = await tester.startGesture(center + const Offset(20, 0));
      await tester.pump();
      expect(count, 1);

      await first.up();
      await second.up();
      await tester.pump();
      expect(count, 1);
      await _disposeAnimateTimers(tester);
    });
  });

  group('CandyPadButton', () {
    testWidgets('default mode still commits on tap-up', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 60,
                child: CandyPadButton(
                  label: '7',
                  onPressed: () => count++,
                ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(CandyPadButton));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(count, 0);

      await gesture.up();
      await tester.pump();
      expect(count, 1);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('commitOnPressDown fires on pointer down', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 60,
                child: CandyPadButton(
                  label: '7',
                  commitOnPressDown: true,
                  onPressed: () => count++,
                ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(CandyPadButton));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(count, 1);

      await gesture.up();
      await tester.pump();
      expect(count, 1);
      await _disposeAnimateTimers(tester);
    });

    testWidgets('commitOnPressDown ignores presses when disabled', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 60,
                child: CandyPadButton(
                  label: '7',
                  enabled: false,
                  commitOnPressDown: true,
                  onPressed: () => count++,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CandyPadButton));
      await tester.pump();
      expect(count, 0);
      await _disposeAnimateTimers(tester);
    });
  });
}
