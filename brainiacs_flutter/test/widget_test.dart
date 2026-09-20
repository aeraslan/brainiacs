import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainiacs_flutter/main.dart';

void main() {
  testWidgets('Brainiacs app loads menu screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrainiacsApp()));

    expect(find.text('Brainiacs'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.text('Profile/Stats'), findsOneWidget);

    // Repeating flutter_animate timers / delayed starts must be disposed before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Practice button opens practice menu with game tiles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: BrainiacsApp()));

    await tester.tap(find.text('Practice'));
    await tester.pump();
    // Allow staggered entrance animations to settle.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Quick Ops'), findsOneWidget);
    expect(find.text('Missing Op'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Recall'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cube Count'),
      80,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    expect(find.text('Cube Count'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Balance'),
      80,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    expect(find.text('Balance'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Asteroids'),
      80,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    expect(find.text('Asteroids'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Color Clash'),
      80,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    expect(find.text('Color Clash'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
