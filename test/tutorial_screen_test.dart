import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/features/tutorial/domain/tutorial_content.dart';
import 'package:brainiacs_flutter/features/tutorial/presentation/tutorial_screen.dart';
import 'package:brainiacs_flutter/features/tutorial/presentation/widgets/tutorial_demo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedTutorialSession extends GameSessionNotifier {
  @override
  GameSessionState build() {
    return GameSessionState(
      totalScore: 0,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.tutorial,
      currentRunSequence: GameSessionState.defaultRunSequence,
      currentIndex: 0,
      scoresByGame: Map<MiniGameType, int>.from(
        GameSessionState.emptyScoresByGame,
      ),
      mathVariant: MathGameVariant.missingOperator,
      analyticVariant: AnalyticGameVariant.cubeCount,
      memoryVariant: MemoryGameVariant.cardMatch,
      visualVariant: VisualGameVariant.visualSort,
    );
  }
}

Future<void> _disposeAnimateTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

Widget _harness({required Size size}) {
  return ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(LocalStorageService.memory()),
      gameSessionProvider.overrideWith(_FixedTutorialSession.new),
    ],
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(home: TutorialScreen()),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TutorialContent', () {
    test('provides Missing Operator steps matching the sprint copy', () {
      final copy = TutorialContent.forType(
        MiniGameType.math,
        mathVariant: MathGameVariant.missingOperator,
      );
      expect(copy.title, 'Missing Operator');
      expect(copy.steps, [
        'Find the missing operator to complete the equation.',
        'Answer correctly to unlock harder equations.',
        'Think fast, but stay accurate!',
      ]);
    });

    test('covers all eight mini-game variants', () {
      final variants = <TutorialContent>[
        TutorialContent.forType(
          MiniGameType.math,
          mathVariant: MathGameVariant.quickMath,
        ),
        TutorialContent.forType(
          MiniGameType.math,
          mathVariant: MathGameVariant.missingOperator,
        ),
        TutorialContent.forType(
          MiniGameType.memory,
          memoryVariant: MemoryGameVariant.cardMatch,
        ),
        TutorialContent.forType(
          MiniGameType.memory,
          memoryVariant: MemoryGameVariant.matrixRecall,
        ),
        TutorialContent.forType(
          MiniGameType.analytical,
          analyticVariant: AnalyticGameVariant.cubeCount,
        ),
        TutorialContent.forType(
          MiniGameType.analytical,
          analyticVariant: AnalyticGameVariant.balanceLogic,
        ),
        TutorialContent.forType(
          MiniGameType.visual,
          visualVariant: VisualGameVariant.visualSort,
        ),
        TutorialContent.forType(
          MiniGameType.visual,
          visualVariant: VisualGameVariant.colorClash,
        ),
      ];

      expect(variants, hasLength(8));
      for (final copy in variants) {
        expect(copy.title, isNotEmpty);
        expect(copy.subtitle, isNotEmpty);
        expect(copy.steps.length, inInclusiveRange(2, 3));
      }
    });
  });

  group('TutorialScreen shell', () {
    testWidgets('shows guided demo chrome on a compact phone', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_harness(size: const Size(320, 568)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('HOW TO PLAY'), findsOneWidget);
      expect(find.text('WATCH FIRST'), findsOneWidget);
      expect(find.text('Missing Operator'), findsWidgets);
      expect(find.text('PLAY!'), findsOneWidget);
      expect(find.byType(TutorialDemoCard), findsOneWidget);
      expect(
        find.text('Find the missing operator to complete the equation.'),
        findsOneWidget,
      );

      await _disposeAnimateTimers(tester);
    });

    testWidgets('keeps PLAY visible on a large phone', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_harness(size: const Size(430, 932)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('HOW TO PLAY'), findsOneWidget);
      expect(find.text('WATCH FIRST'), findsOneWidget);
      expect(find.text('PLAY!'), findsOneWidget);
      expect(find.text('Think fast, but stay accurate!'), findsOneWidget);

      await _disposeAnimateTimers(tester);
    });

    testWidgets('demo area absorbs taps without leaving tutorial', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          localStorageProvider.overrideWithValue(LocalStorageService.memory()),
          gameSessionProvider.overrideWith(_FixedTutorialSession.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MediaQuery(
            data: MediaQueryData(size: Size(390, 844)),
            child: MaterialApp(home: TutorialScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final demo = find.byType(TutorialDemoCard);
      expect(demo, findsOneWidget);

      await tester.tap(demo);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(container.read(gameSessionProvider).phase, GamePhase.tutorial);
      expect(container.read(gameSessionProvider).totalScore, 0);
      expect(find.text('PLAY!'), findsOneWidget);
      expect(find.text('WATCH FIRST'), findsOneWidget);

      await _disposeAnimateTimers(tester);
    });
  });
}
