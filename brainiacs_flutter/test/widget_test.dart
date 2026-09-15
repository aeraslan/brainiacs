import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainiacs_flutter/main.dart';

void main() {
  testWidgets('Brainiacs app loads menu screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrainiacsApp()));

    expect(find.text('Brainiacs'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byTooltip('Leaderboard'), findsOneWidget);
    expect(find.text('Profile/Stats'), findsOneWidget);

    // Repeating flutter_animate timers / delayed starts must be disposed before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
