import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:brainiacs_flutter/core/rank/title_tier_l10n.dart';
import 'package:brainiacs_flutter/core/theme/app_theme.dart';
import 'package:brainiacs_flutter/features/score/presentation/widgets/rank_ladder_sheet.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _ladderHost({
  required Locale locale,
  required TitleTier heldTitle,
  required Size size,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    RankLadderSheet.show(context, heldTitle: heldTitle),
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _openLadder(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _ensureVisibleInList(WidgetTester tester, Finder item) async {
  if (item.evaluate().isNotEmpty) {
    await tester.ensureVisible(item);
    await tester.pumpAndSettle();
    return;
  }
  await tester.dragUntilVisible(
    item,
    find.byType(ListView),
    const Offset(0, -80),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows all eight English names and descriptions', (tester) async {
    final overflowErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed') || message.contains('RenderFlex')) {
        overflowErrors.add(details);
      }
      previousOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = previousOnError;
    });

    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _ladderHost(
        locale: const Locale('en'),
        heldTitle: TitleTier.activeNeuron,
        size: size,
      ),
    );
    await _openLadder(tester);

    expect(find.text(en.rankAllRanks), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    // Sheet lists highest → lowest; walk in that order while scrolling down.
    for (final tier in TitleTier.values.reversed) {
      final name = find.text(tier.localizedName(en));
      final description = find.text(tier.localizedDescription(en));
      await _ensureVisibleInList(tester, name);
      expect(name, findsOneWidget);
      await _ensureVisibleInList(tester, description);
      expect(description, findsOneWidget);
    }

    expect(overflowErrors, isEmpty);
  });

  testWidgets('shows all eight Turkish names and descriptions', (tester) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final tr = await AppLocalizations.delegate.load(const Locale('tr'));
    await tester.pumpWidget(
      _ladderHost(
        locale: const Locale('tr'),
        heldTitle: TitleTier.dormantMind,
        size: size,
      ),
    );
    await _openLadder(tester);

    for (final tier in TitleTier.values.reversed) {
      final name = find.text(tier.localizedName(tr));
      final description = find.text(tier.localizedDescription(tr));
      await _ensureVisibleInList(tester, name);
      expect(name, findsOneWidget);
      await _ensureVisibleInList(tester, description);
      expect(description, findsOneWidget);
    }
  });

  testWidgets('compact sheet remains scrollable without overflow', (
    tester,
  ) async {
    final overflowErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed') || message.contains('RenderFlex')) {
        overflowErrors.add(details);
      }
      previousOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = previousOnError;
    });

    const size = Size(320, 568);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _ladderHost(
        locale: const Locale('en'),
        heldTitle: TitleTier.brainiac,
        size: size,
        textScale: 1.5,
      ),
    );
    await _openLadder(tester);

    expect(find.text(en.rankAllRanks), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    final bottomDescription = find.text(
      TitleTier.dormantMind.localizedDescription(en),
    );
    await _ensureVisibleInList(tester, bottomDescription);
    expect(bottomDescription, findsOneWidget);
    expect(overflowErrors, isEmpty);
  });
}
