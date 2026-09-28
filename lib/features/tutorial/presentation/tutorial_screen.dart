import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_controller_provider.dart';
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

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final GlobalKey _overlayKey = GlobalKey();
  final GlobalKey _boardKey = GlobalKey();
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
                  Expanded(
                    child: Stack(
                      key: _boardKey,
                      fit: StackFit.expand,
                      children: [
                        Column(
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
                                // Invisible spacer so the live banner above the dim
                                // keeps correct vertical layout without a ghost double.
                                child: Visibility(
                                  visible: false,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child: _TutorialBanner(
                                    title: copy.title,
                                    instruction: copy.instruction,
                                  ),
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
                          ],
                        ),
                        // Dim from the top edge down through the board (behind chrome).
                        _TutorialDimOverlay(
                          controller: _pointerController,
                          boardKey: _boardKey,
                          overlayKey: _overlayKey,
                        ),
                        // Banner redrawn above the dim so title/subtitle stay crisp.
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.sm,
                              ),
                              child: _TutorialBanner(
                                title: copy.title,
                                instruction: copy.instruction,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        child: CandyButton(
                              label: 'PLAY!',
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

/// Dims the mock board; punches a soft spotlight hole around the demo target.
class _TutorialDimOverlay extends StatelessWidget {
  const _TutorialDimOverlay({
    required this.controller,
    required this.boardKey,
    required this.overlayKey,
  });

  final TutorialPointerController controller;
  final GlobalKey boardKey;
  final GlobalKey overlayKey;

  Rect? _toBoardLocal(Rect? overlayRect) {
    if (overlayRect == null) {
      return null;
    }
    final board = boardKey.currentContext?.findRenderObject();
    final overlay = overlayKey.currentContext?.findRenderObject();
    if (board is! RenderBox || overlay is! RenderBox) {
      return null;
    }

    final topLeft = board.globalToLocal(
      overlay.localToGlobal(overlayRect.topLeft),
    );
    final bottomRight = board.globalToLocal(
      overlay.localToGlobal(overlayRect.bottomRight),
    );
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Rect?>(
      valueListenable: controller.spotlightRect,
      builder: (context, overlayRect, _) {
        final hole = _toBoardLocal(overlayRect);
        return IgnorePointer(
          child: CustomPaint(
            painter: _SpotlightDimPainter(hole: hole),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _SpotlightDimPainter extends CustomPainter {
  const _SpotlightDimPainter({required this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final dimPath = Path()..addRect(bounds);
    RRect? holeRRect;

    if (hole != null) {
      final clipped = hole!.intersect(bounds);
      if (!clipped.isEmpty) {
        holeRRect = RRect.fromRectAndRadius(
          clipped,
          const Radius.circular(AppSpacing.md),
        );
        dimPath
          ..addRRect(holeRRect)
          ..fillType = PathFillType.evenOdd;
      }
    }

    canvas.drawPath(dimPath, Paint()..color = Colors.black54);

    if (holeRRect != null) {
      final glowPaint = Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(holeRRect.inflate(2), glowPaint);

      final rimPaint = Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(holeRRect, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightDimPainter oldDelegate) {
    return oldDelegate.hole != hole;
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
  const _TutorialCopy({required this.title, required this.instruction});

  final String title;
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
          title: 'Quick Math',
          instruction: 'Find the correct answer.',
        ),
        MathGameVariant.missingOperator => const _TutorialCopy(
          title: 'Missing Operator',
          instruction: 'Pick the missing operator.',
        ),
      },
      MiniGameType.memory => switch (memoryVariant) {
        MemoryGameVariant.cardMatch => const _TutorialCopy(
          title: 'Card Match',
          instruction: 'Memorize the cards and match them.',
        ),
        MemoryGameVariant.matrixRecall => const _TutorialCopy(
          title: 'Matrix Recall',
          instruction: 'Watch the sequence, then tap it back.',
        ),
      },
      MiniGameType.analytical => switch (analyticVariant) {
        AnalyticGameVariant.cubeCount => const _TutorialCopy(
          title: 'Cube Count',
          instruction: 'Count how many cubes are on the screen.',
        ),
        AnalyticGameVariant.balanceLogic => const _TutorialCopy(
          title: 'Balance Logic',
          instruction: 'Pick the heaviest object.',
        ),
      },
      MiniGameType.visual => switch (visualVariant) {
        VisualGameVariant.visualSort => const _TutorialCopy(
          title: 'Asteroids',
          instruction: 'Tap the asteroids in ascending order.',
        ),
        VisualGameVariant.colorClash => const _TutorialCopy(
          title: 'Color Clash',
          instruction: 'Follow the rule: match the ink or the word.',
        ),
      },
    };
  }
}

class _TutorialBanner extends StatelessWidget {
  const _TutorialBanner({
    required this.title,
    required this.instruction,
  });

  final String title;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w900,
      height: 1.1,
    );

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle?.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..strokeJoin = StrokeJoin.round
                  ..color = Colors.black87,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle?.copyWith(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
