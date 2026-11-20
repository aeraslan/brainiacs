import 'package:brainiacs_flutter/core/audio/audio_controller_provider.dart';
import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:brainiacs_flutter/core/rank/title_tier_l10n.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/core/theme/app_theme.dart';
import 'package:brainiacs_flutter/features/score/presentation/widgets/rank_defend_chip.dart';
import 'package:brainiacs_flutter/features/score/presentation/widgets/rank_reveal_dialog.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _revealHost({
  required ProviderContainer container,
  required TitleTier earnedTitle,
  required RankDefendOutcome? outcome,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  double textScale = 1,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => RankRevealDialog.show(
                    context,
                    earnedTitle: earnedTitle,
                    outcome: outcome,
                  ),
                  child: const Text('Reveal'),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      localStorageProvider.overrideWithValue(LocalStorageService.memory()),
    ],
  );
}

Future<void> _openReveal(WidgetTester tester) async {
  await tester.tap(find.text('Reveal'));
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

Future<void> _advanceToLanding(WidgetTester tester) async {
  // Advance the 5s spin, then flush the forward() Future so onLocked runs.
  await tester.pump(const Duration(milliseconds: 5000));
  await tester.pump();
}

Future<void> _advanceToResult(WidgetTester tester) async {
  // Landing hold (600ms), then drain AnimatedSwitcher + entrance animations.
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('hides celebration content while spinning', (tester) async {
    final container = _container();
    addTearDown(container.dispose);
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      _revealHost(
        container: container,
        earnedTitle: TitleTier.analyticMind,
        outcome: RankDefendOutcome.unlocked,
      ),
    );
    await _openReveal(tester);

    expect(find.text(en.scoreYourRank), findsOneWidget);
    expect(find.text(en.rankRevealPromotionHeading), findsNothing);
    expect(find.text(en.rankRevealDefendedHeading), findsNothing);
    expect(find.text(en.rankRevealSessionHeading), findsNothing);
    expect(
      find.text(TitleTier.analyticMind.localizedDescription(en)),
      findsNothing,
    );
    expect(find.text(en.scoreNice), findsNothing);

    await tester.tapAt(const Offset(20, 20));
    await tester.pump();
    expect(find.text(en.scoreYourRank), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('holds landing without result for 600ms after lock', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      _revealHost(
        container: container,
        earnedTitle: TitleTier.mindApprentice,
        outcome: RankDefendOutcome.defended,
      ),
    );
    await _openReveal(tester);
    await _advanceToLanding(tester);

    expect(find.text(en.scoreYourRank), findsOneWidget);
    expect(find.text(en.rankRevealDefendedHeading), findsNothing);
    expect(find.text(en.scoreNice), findsNothing);
    expect(find.text(TitleTier.mindApprentice.localizedName(en)), findsWidgets);

    await _disposeAnimatedTree(tester);
  });

  testWidgets(
    'shows result after landing hold with correct promotion content',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.pumpWidget(
        _revealHost(
          container: container,
          earnedTitle: TitleTier.analyticMind,
          outcome: RankDefendOutcome.unlocked,
        ),
      );
      await _openReveal(tester);
      await _advanceToLanding(tester);
      await _advanceToResult(tester);

      expect(find.text(en.rankRevealPromotionHeading), findsOneWidget);
      expect(find.text(en.rankRevealDefendedHeading), findsNothing);
      expect(find.text(en.rankRevealSessionHeading), findsNothing);
      expect(
        find.text(TitleTier.analyticMind.localizedName(en)),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text(TitleTier.analyticMind.localizedDescription(en)),
        findsOneWidget,
      );
      expect(find.text(en.scoreNice), findsOneWidget);

      await _disposeAnimatedTree(tester);
    },
  );

  testWidgets('shows defended and session headings for their outcomes', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      _revealHost(
        container: container,
        earnedTitle: TitleTier.activeNeuron,
        outcome: RankDefendOutcome.defended,
      ),
    );
    await _openReveal(tester);
    await _advanceToLanding(tester);
    await _advanceToResult(tester);

    expect(find.text(en.rankRevealDefendedHeading), findsOneWidget);
    expect(find.text(en.rankRevealPromotionHeading), findsNothing);
    expect(find.text(en.rankRevealSessionHeading), findsNothing);

    await _disposeAnimatedTree(tester);

    final container2 = _container();
    addTearDown(container2.dispose);
    await tester.pumpWidget(
      _revealHost(
        container: container2,
        earnedTitle: TitleTier.dormantMind,
        outcome: RankDefendOutcome.pending,
      ),
    );
    await _openReveal(tester);
    await _advanceToLanding(tester);
    await _advanceToResult(tester);

    expect(find.text(en.rankRevealSessionHeading), findsOneWidget);
    expect(find.text(en.rankRevealPromotionHeading), findsNothing);
    expect(find.text(en.rankRevealDefendedHeading), findsNothing);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('Turkish outcome headings render correctly', (tester) async {
    final container = _container();
    addTearDown(container.dispose);
    final tr = await AppLocalizations.delegate.load(const Locale('tr'));

    await tester.pumpWidget(
      _revealHost(
        container: container,
        earnedTitle: TitleTier.analyticMind,
        outcome: RankDefendOutcome.unlocked,
        locale: const Locale('tr'),
      ),
    );
    await _openReveal(tester);
    await _advanceToLanding(tester);
    await _advanceToResult(tester);

    expect(find.text(tr.rankRevealPromotionHeading), findsOneWidget);
    expect(
      find.text(TitleTier.analyticMind.localizedDescription(tr)),
      findsOneWidget,
    );

    await _disposeAnimatedTree(tester);
  });

  testWidgets('slot spin is started once and result appears once', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    // Warm the audio notifier so the dialog shares this container instance.
    container.read(audioControllerProvider.notifier);

    await tester.pumpWidget(
      _revealHost(
        container: container,
        earnedTitle: TitleTier.sharpIntellect,
        outcome: null,
      ),
    );
    await _openReveal(tester);
    await _advanceToLanding(tester);
    expect(find.text(en.scoreNice), findsNothing);

    await _advanceToResult(tester);
    expect(find.text(en.rankRevealSessionHeading), findsOneWidget);
    expect(find.text(en.scoreNice), findsOneWidget);
    expect(
      find.text(TitleTier.sharpIntellect.localizedDescription(en)),
      findsOneWidget,
    );

    await _disposeAnimatedTree(tester);
  });

  testWidgets('Continue dismisses once and ignores double tap', (tester) async {
    final container = _container();
    addTearDown(container.dispose);
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      _revealHost(
        container: container,
        earnedTitle: TitleTier.dormantMind,
        outcome: null,
      ),
    );
    await _openReveal(tester);
    await _advanceToLanding(tester);
    await _advanceToResult(tester);

    expect(find.text(en.scoreNice), findsOneWidget);
    await tester.tap(find.text(en.scoreNice));
    await tester.pump();
    // Second tap must be ignored after the first dismiss starts.
    if (find.text(en.scoreNice).evaluate().isNotEmpty) {
      await tester.tap(find.text(en.scoreNice), warnIfMissed: false);
    }
    await tester.pumpAndSettle();

    expect(find.text(en.rankRevealSessionHeading), findsNothing);
    expect(find.text(en.scoreNice), findsNothing);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('result layout has no overflow across viewports and text scale', (
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

    const viewports = <Size>[
      Size(320, 568),
      Size(375, 667),
      Size(390, 844),
      Size(412, 915),
    ];

    for (final size in viewports) {
      overflowErrors.clear();
      final container = _container();
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        _revealHost(
          container: container,
          earnedTitle: TitleTier.dormantMind,
          outcome: RankDefendOutcome.unlocked,
          locale: const Locale('tr'),
          size: size,
          textScale: size.width <= 320 ? 1.3 : 1,
        ),
      );
      await _openReveal(tester);
      await _advanceToLanding(tester);
      await _advanceToResult(tester);

      expect(find.text('Tek Hücreli Yaşam Formu'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Evrim uzun bir yolculuk'), findsOneWidget);
      expect(overflowErrors, isEmpty, reason: 'overflow at $size');

      await _disposeAnimatedTree(tester);
    }

    await tester.binding.setSurfaceSize(null);
  });
}
