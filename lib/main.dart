import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/audio/audio_controller_provider.dart';
import 'core/localization/locale_provider.dart';
import 'core/session/game_session_notifier.dart';
import 'core/session/game_session_state.dart';
import 'core/storage/local_storage_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/analytical/presentation/balance_logic_screen.dart';
import 'features/analytical/presentation/cube_count_screen.dart';
import 'features/math/presentation/missing_operator_screen.dart';
import 'features/math/presentation/quick_math_screen.dart';
import 'features/memory/presentation/card_match_screen.dart';
import 'features/memory/presentation/matrix_recall_screen.dart';
import 'features/menu/presentation/main_menu_screen.dart';
import 'features/menu/presentation/practice_countdown_screen.dart';
import 'features/menu/presentation/practice_menu_screen.dart';
import 'features/score/presentation/score_screen.dart';
import 'features/score/presentation/times_up_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/statistics/presentation/my_progress_screen.dart';
import 'features/tutorial/presentation/tutorial_screen.dart';
import 'features/visual/presentation/color_clash_screen.dart';
import 'features/visual/presentation/visual_sort_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(LocalStorageService.boxName);
  runApp(const ProviderScope(child: BrainiacsApp()));
}

class BrainiacsApp extends ConsumerWidget {
  const BrainiacsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagePreference = ref.watch(languagePreferenceProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeForPreference(languagePreference),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: (locales, _) => resolveAppLocale(locales),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(audioControllerProvider.notifier).playMenuBGM();
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(gameSessionProvider.select((state) => state.phase));
    final currentGame = ref.watch(
      gameSessionProvider.select((state) => state.currentGame),
    );
    final mathVariant = ref.watch(
      gameSessionProvider.select((state) => state.mathVariant),
    );
    final analyticVariant = ref.watch(
      gameSessionProvider.select((state) => state.analyticVariant),
    );
    final memoryVariant = ref.watch(
      gameSessionProvider.select((state) => state.memoryVariant),
    );
    final visualVariant = ref.watch(
      gameSessionProvider.select((state) => state.visualVariant),
    );

    return switch (phase) {
      GamePhase.menu => const MainMenuScreen(),
      GamePhase.practiceMenu => const PracticeMenuScreen(),
      GamePhase.myProgress => const MyProgressScreen(),
      GamePhase.settings => const SettingsScreen(),
      GamePhase.tutorial => const TutorialScreen(),
      GamePhase.countdown => const PracticeCountdownScreen(),
      GamePhase.playing => switch (currentGame) {
        MiniGameType.math => switch (mathVariant) {
          MathGameVariant.quickMath => const QuickMathScreen(),
          MathGameVariant.missingOperator => const MissingOperatorScreen(),
        },
        MiniGameType.memory => switch (memoryVariant) {
          MemoryGameVariant.cardMatch => const CardMatchScreen(),
          MemoryGameVariant.matrixRecall => const MatrixRecallScreen(),
        },
        MiniGameType.analytical => switch (analyticVariant) {
          AnalyticGameVariant.cubeCount => const CubeCountScreen(),
          AnalyticGameVariant.balanceLogic => const BalanceLogicScreen(),
        },
        MiniGameType.visual => switch (visualVariant) {
          VisualGameVariant.visualSort => const VisualSortScreen(),
          VisualGameVariant.colorClash => const ColorClashScreen(),
        },
      },
      GamePhase.timesUp => const TimesUpScreen(),
      GamePhase.scoreScreen => const ScoreScreen(),
    };
  }
}
