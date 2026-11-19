import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/features/menu/presentation/main_menu_screen.dart';
import 'package:brainiacs_flutter/features/settings/presentation/settings_screen.dart';
import 'package:brainiacs_flutter/features/statistics/presentation/my_progress_screen.dart';
import 'package:brainiacs_flutter/features/tutorial/presentation/tutorial_screen.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:brainiacs_flutter/shared/widgets/pause_menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _compact = Size(320, 568);

Widget _trApp({
  required Widget home,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(LocalStorageService.memory()),
      ...overrides,
    ],
    child: MediaQuery(
      data: const MediaQueryData(size: _compact),
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    ),
  );
}

class _TutorialSession extends GameSessionNotifier {
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
      mathVariant: MathGameVariant.quickMath,
      analyticVariant: AnalyticGameVariant.cubeCount,
      memoryVariant: MemoryGameVariant.cardMatch,
      visualVariant: VisualGameVariant.visualSort,
    );
  }
}

class _ProgressSession extends GameSessionNotifier {
  @override
  GameSessionState build() {
    return GameSessionState(
      totalScore: 0,
      timeRemaining: GameSessionState.maxTimeLimit,
      phase: GamePhase.myProgress,
      currentRunSequence: GameSessionState.defaultRunSequence,
      currentIndex: 0,
      scoresByGame: Map<MiniGameType, int>.from(
        GameSessionState.emptyScoresByGame,
      ),
      mathVariant: MathGameVariant.quickMath,
      analyticVariant: AnalyticGameVariant.cubeCount,
      memoryVariant: MemoryGameVariant.cardMatch,
      visualVariant: VisualGameVariant.visualSort,
    );
  }
}

Future<void> _disposeAnimate(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Turkish main menu fits compact layout', (tester) async {
    await tester.pumpWidget(_trApp(home: const MainMenuScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Brainiacs'), findsOneWidget);
    expect(find.text('Yeni Oyun'), findsOneWidget);
    expect(find.text('Antrenman'), findsOneWidget);
    expect(find.text('Gelişimim'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeAnimate(tester);
  });

  testWidgets('Turkish settings fits compact layout', (tester) async {
    await tester.pumpWidget(_trApp(home: const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Sistem Varsayılanı'), findsOneWidget);
    expect(find.text('Ses Efektleri'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkish pause menu fits compact layout', (tester) async {
    await tester.pumpWidget(
      _trApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    PauseMenuDialog.show(context, isPracticeMode: true);
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Duraklatıldı'), findsOneWidget);
    expect(find.text('Devam Et'), findsOneWidget);
    expect(find.text('Antrenmanı Bitir'), findsOneWidget);
    expect(find.text('Ana Menüye Dön'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkish tutorial and My Progress render without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _trApp(
        home: const TutorialScreen(),
        overrides: [
          gameSessionProvider.overrideWith(_TutorialSession.new),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('NASIL OYNANIR?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeAnimate(tester);

    await tester.pumpWidget(
      _trApp(
        home: const MyProgressScreen(),
        overrides: [
          gameSessionProvider.overrideWith(_ProgressSession.new),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Gelişimim'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeAnimate(tester);
  });
}
