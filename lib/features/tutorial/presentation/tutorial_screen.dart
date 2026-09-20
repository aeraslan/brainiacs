import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/countdown_overlay.dart';
import '../../../shared/widgets/game_screen_background.dart';
import '../../analytical/presentation/balance_logic_screen.dart';
import '../../analytical/presentation/cube_count_screen.dart';
import '../../math/presentation/missing_operator_screen.dart';
import '../../math/presentation/quick_math_screen.dart';
import '../../memory/presentation/card_match_screen.dart';
import '../../memory/presentation/matrix_recall_screen.dart';
import '../../visual/presentation/color_clash_screen.dart';
import '../../visual/presentation/visual_colors.dart';
import '../../visual/presentation/visual_sort_screen.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final GlobalKey _overlayKey = GlobalKey();
  late final TutorialPointerController _pointerController;
  bool _showCountdown = false;

  @override
  void initState() {
    super.initState();
    _pointerController = TutorialPointerController(overlayKey: _overlayKey);
  }

  @override
  void dispose() {
    _pointerController.dispose();
    super.dispose();
  }

  void _onReady() {
    if (_showCountdown) {
      return;
    }
    _pointerController.hide();
    setState(() {
      _showCountdown = true;
    });
  }

  void _onCountdownComplete() {
    ref.read(gameSessionProvider.notifier).beginPlaying();
  }

  Color _accentFor(MiniGameType type) {
    return switch (type) {
      MiniGameType.math => const Color(0xFFFFE566),
      MiniGameType.memory => const Color(0xFFA8E6A3),
      MiniGameType.analytical => const Color(0xFFFFBE7D),
      MiniGameType.visual => VisualColors.sky,
    };
  }

  @override
  Widget build(BuildContext context) {
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
    final stageNumber = ref.watch(
      gameSessionProvider.select((state) => state.stageNumber),
    );
    final stageCount = ref.watch(
      gameSessionProvider.select((state) => state.stageCount),
    );
    final copy = _TutorialCopy.forType(
      currentGame,
      mathVariant: mathVariant,
      analyticVariant: analyticVariant,
      memoryVariant: memoryVariant,
      visualVariant: visualVariant,
    );

    if (_showCountdown) {
      return Scaffold(
        backgroundColor: AppColors.textPrimary,
        body: CountdownOverlay(
          onComplete: _onCountdownComplete,
          accentColor: _accentFor(currentGame),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _scaffoldColorFor(currentGame),
      body: _TutorialPageBackground(
        type: currentGame,
        child: Stack(
          key: _overlayKey,
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: _TutorialBanner(
                        stageNumber: stageNumber,
                        stageCount: stageCount,
                        instruction: copy.instruction,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: IgnorePointer(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: _TutorialGameHost(
                            type: currentGame,
                            mathVariant: mathVariant,
                            analyticVariant: analyticVariant,
                            memoryVariant: memoryVariant,
                            visualVariant: visualVariant,
                            autoPlay: true,
                            pointerController: _pointerController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onReady,
                          child: const Text('Ready!'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TutorialPointer(controller: _pointerController),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed backdrop matching normal play screens (covers banner + Ready).
class _TutorialPageBackground extends StatelessWidget {
  const _TutorialPageBackground({required this.type, required this.child});

  final MiniGameType type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      MiniGameType.math => GameScreenBackground(
        style: GameBackgroundStyle.mathYellow,
        child: child,
      ),
      MiniGameType.memory => GameScreenBackground(
        style: GameBackgroundStyle.memoryGreen,
        child: child,
      ),
      MiniGameType.analytical => GameScreenBackground(
        style: GameBackgroundStyle.cubeOrange,
        child: child,
      ),
      MiniGameType.visual => ColoredBox(color: VisualColors.sky, child: child),
    };
  }
}

Color _scaffoldColorFor(MiniGameType type) {
  return switch (type) {
    MiniGameType.math => GameScreenBackground.scaffoldColorFor(
      GameBackgroundStyle.mathYellow,
    ),
    MiniGameType.memory => GameScreenBackground.scaffoldColorFor(
      GameBackgroundStyle.memoryGreen,
    ),
    MiniGameType.analytical => GameScreenBackground.scaffoldColorFor(
      GameBackgroundStyle.cubeOrange,
    ),
    MiniGameType.visual => VisualColors.sky,
  };
}

class _TutorialGameHost extends StatelessWidget {
  const _TutorialGameHost({
    required this.type,
    required this.mathVariant,
    required this.analyticVariant,
    required this.memoryVariant,
    required this.visualVariant,
    required this.autoPlay,
    required this.pointerController,
  });

  final MiniGameType type;
  final MathGameVariant mathVariant;
  final AnalyticGameVariant analyticVariant;
  final MemoryGameVariant memoryVariant;
  final VisualGameVariant visualVariant;
  final bool autoPlay;
  final TutorialPointerController pointerController;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      MiniGameType.math => switch (mathVariant) {
        MathGameVariant.quickMath => QuickMathScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
        MathGameVariant.missingOperator => MissingOperatorScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
      },
      MiniGameType.memory => switch (memoryVariant) {
        MemoryGameVariant.cardMatch => CardMatchScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
        MemoryGameVariant.matrixRecall => MatrixRecallScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
      },
      MiniGameType.analytical => switch (analyticVariant) {
        AnalyticGameVariant.cubeCount => CubeCountScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
        AnalyticGameVariant.balanceLogic => BalanceLogicScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
      },
      MiniGameType.visual => switch (visualVariant) {
        VisualGameVariant.visualSort => VisualSortScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
        VisualGameVariant.colorClash => ColorClashScreen(
          isTutorial: true,
          autoPlay: autoPlay,
          pointerController: pointerController,
        ),
      },
    };
  }
}

class _TutorialCopy {
  const _TutorialCopy({required this.instruction});

  final String instruction;

  static _TutorialCopy forType(
    MiniGameType type, {
    MathGameVariant mathVariant = MathGameVariant.quickMath,
    AnalyticGameVariant analyticVariant = AnalyticGameVariant.cubeCount,
    MemoryGameVariant memoryVariant = MemoryGameVariant.cardMatch,
    VisualGameVariant visualVariant = VisualGameVariant.visualSort,
  }) {
    return switch (type) {
      MiniGameType.math => switch (mathVariant) {
        MathGameVariant.quickMath => const _TutorialCopy(
          instruction: 'Find the correct answer.',
        ),
        MathGameVariant.missingOperator => const _TutorialCopy(
          instruction: 'Pick the missing operator.',
        ),
      },
      MiniGameType.memory => switch (memoryVariant) {
        MemoryGameVariant.cardMatch => const _TutorialCopy(
          instruction: 'Memorize the cards and match them.',
        ),
        MemoryGameVariant.matrixRecall => const _TutorialCopy(
          instruction: 'Watch the sequence, then tap it back.',
        ),
      },
      MiniGameType.analytical => switch (analyticVariant) {
        AnalyticGameVariant.cubeCount => const _TutorialCopy(
          instruction: 'Count how many cubes are on the screen.',
        ),
        AnalyticGameVariant.balanceLogic => const _TutorialCopy(
          instruction: 'Pick the heaviest object.',
        ),
      },
      MiniGameType.visual => switch (visualVariant) {
        VisualGameVariant.visualSort => const _TutorialCopy(
          instruction: 'Tap the asteroids in ascending order.',
        ),
        VisualGameVariant.colorClash => const _TutorialCopy(
          instruction: 'Follow the rule: match the ink or the word.',
        ),
      },
    };
  }
}

class _TutorialBanner extends StatelessWidget {
  const _TutorialBanner({
    required this.stageNumber,
    required this.stageCount,
    required this.instruction,
  });

  final int stageNumber;
  final int stageCount;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(AppSpacing.md),
      elevation: 1,
      shadowColor: AppColors.shadow,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              'Stage $stageNumber / $stageCount',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              instruction,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
