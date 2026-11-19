import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_controller_provider.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/candy_button.dart';
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
import '../domain/tutorial_content.dart';
import 'widgets/tutorial_demo_card.dart';
import 'widgets/tutorial_header.dart';
import 'widgets/tutorial_step_list.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final GlobalKey _overlayKey = GlobalKey();
  late final TutorialPointerController _pointerController;
  bool _showCountdown = false;

  static const double _compactHeightBreakpoint = 640;

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
    // Play as soon as the overlay is shown (reliable after Play Again too).
    ref.read(audioControllerProvider.notifier).playCountdown();
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
    final copy = TutorialContent.forType(
      currentGame,
      context.l10n,
      mathVariant: mathVariant,
      analyticVariant: analyticVariant,
      memoryVariant: memoryVariant,
      visualVariant: visualVariant,
    );
    final accent = _accentFor(currentGame);

    if (_showCountdown) {
      return Scaffold(
        backgroundColor: AppColors.textPrimary,
        body: CountdownOverlay(
          onComplete: _onCountdownComplete,
          accentColor: accent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: _scaffoldColorFor(currentGame),
      body: _TutorialPageBackground(
        type: currentGame,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxHeight < _compactHeightBreakpoint;
              final horizontal = compact ? AppSpacing.md : AppSpacing.lg;
              final verticalGap = compact ? AppSpacing.sm : AppSpacing.md;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppSpacing.sm,
                  horizontal,
                  AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    TutorialHeader(
                      title: copy.title,
                      subtitle: copy.subtitle,
                      accentColor: accent,
                    ),
                    SizedBox(height: verticalGap),
                    Expanded(
                      child: TutorialDemoCard(
                        overlayKey: _overlayKey,
                        pointerController: _pointerController,
                        accentColor: accent,
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
                    SizedBox(height: verticalGap),
                    TutorialStepList(
                      steps: copy.steps,
                      accentColor: accent,
                      compact: compact,
                    ),
                    SizedBox(height: verticalGap),
                    SizedBox(
                      width: double.infinity,
                      child: CandyButton(
                            label: context.l10n.tutorialPlay,
                            variant: CandyButtonVariant.green,
                            onPressed: _onReady,
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 700.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Full-bleed backdrop matching normal play screens.
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
