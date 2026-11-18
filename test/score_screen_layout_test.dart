import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/core/theme/app_theme.dart';
import 'package:brainiacs_flutter/features/score/presentation/score_screen.dart';

Widget _scoreScreenApp({required Size size}) {
  return ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(LocalStorageService.memory()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const ScoreScreen(),
      ),
    ),
  );
}

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const viewports = <Size>[
    Size(320, 568),
    Size(375, 667),
    Size(390, 844),
    Size(412, 915),
  ];

  for (final size in viewports) {
    testWidgets(
      'ScoreScreen keeps Play Again and Menu visible at '
      '${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        final overflowErrors = <FlutterErrorDetails>[];
        final previousOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          final message = details.exceptionAsString();
          if (message.contains('overflowed') ||
              message.contains('RenderFlex')) {
            overflowErrors.add(details);
          }
          previousOnError?.call(details);
        };
        addTearDown(() {
          FlutterError.onError = previousOnError;
        });

        await tester.binding.setSurfaceSize(size);
        addTearDown(() async {
          await tester.binding.setSurfaceSize(null);
        });

        await tester.pumpWidget(_scoreScreenApp(size: size));
        await tester.pump();
        // Settle entrance animations without waiting for rank reveal.
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Play Again'), findsOneWidget);
        expect(find.text('Menu'), findsOneWidget);
        expect(overflowErrors, isEmpty);

        await _disposeAnimatedTree(tester);
      },
    );
  }
}
