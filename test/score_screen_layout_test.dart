import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/core/theme/app_theme.dart';
import 'package:brainiacs_flutter/features/score/presentation/score_screen.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';

Widget _scoreScreenApp({required Size size}) {
  return ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(LocalStorageService.memory()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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

  testWidgets(
    'shows Scroll for more when results overflow the viewport',
    (tester) async {
      const size = Size(320, 480);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(_scoreScreenApp(size: size));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // Allow post-frame overflow sync.
      await tester.pump();

      expect(find.text('Scroll for more'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);

      await _disposeAnimatedTree(tester);
    },
  );

  testWidgets(
    'hides Scroll for more when results fit without scrolling',
    (tester) async {
      const size = Size(400, 1200);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(_scoreScreenApp(size: size));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Scroll for more'), findsNothing);
      expect(find.text('Play Again'), findsOneWidget);

      await _disposeAnimatedTree(tester);
    },
  );

  testWidgets(
    'dismisses Scroll for more after the user scrolls down',
    (tester) async {
      const size = Size(320, 480);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(_scoreScreenApp(size: size));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Scroll for more'), findsOneWidget);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scroll for more'), findsNothing);

      // Scrolling back to top must not revive the cue for this visit.
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 120));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scroll for more'), findsNothing);

      await _disposeAnimatedTree(tester);
    },
  );
}
