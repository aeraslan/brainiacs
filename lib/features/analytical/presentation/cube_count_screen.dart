import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/answer_feedback_burst.dart';
import '../../../shared/widgets/game_hud.dart';
import '../../../shared/widgets/game_screen_background.dart';
import '../../../shared/widgets/number_pad.dart';
import 'cube_count_notifier.dart';
import 'widgets/isometric_cube_board.dart';

enum _AnswerFeedback { none, correct, incorrect }

class CubeCountScreen extends ConsumerStatefulWidget {
  const CubeCountScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<CubeCountScreen> createState() => _CubeCountScreenState();
}

class _CubeCountScreenState extends ConsumerState<CubeCountScreen> {
  bool _isAcceptingInput = false;
  _AnswerFeedback _feedback = _AnswerFeedback.none;

  static const int correctPoints = 100;
  static const int incorrectPenalty = -20;
  static const Duration feedbackDelay = Duration(milliseconds: 500);

  final Map<int, GlobalKey> _digitKeys = {
    for (var digit = 0; digit <= 9; digit++) digit: GlobalKey(),
  };
  int _tutorialToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cubeCountProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(CubeCountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay && !widget.autoPlay) {
      _tutorialToken++;
      widget.pointerController?.hide();
    }
  }

  @override
  void dispose() {
    _tutorialToken++;
    super.dispose();
  }

  bool _isTutorialActive(int token) {
    return mounted &&
        token == _tutorialToken &&
        widget.isTutorial &&
        widget.autoPlay;
  }

  Future<void> _runTutorial() async {
    final token = ++_tutorialToken;
    if (widget.pointerController == null) {
      return;
    }

    await waitUntil(
      () => _digitKeys[0]?.currentContext != null,
      isActive: () => _isTutorialActive(token),
    );

    while (_isTutorialActive(token)) {
      await _playCubeAnswer(correct: true, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!_isTutorialActive(token)) {
        return;
      }
      await _playCubeAnswer(correct: false, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  Future<void> _playCubeAnswer({
    required bool correct,
    required int token,
  }) async {
    final pointer = widget.pointerController;
    if (pointer == null || !_isTutorialActive(token)) {
      return;
    }

    await waitUntil(
      () => _isAcceptingInput,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    final puzzle = ref.read(cubeCountProvider);
    final digits = correct
        ? puzzle.expectedTotal.toString()
        : wrongDigitString(puzzle.expectedTotal, puzzle.requiredDigitCount);

    for (final character in digits.split('')) {
      if (!_isTutorialActive(token)) {
        return;
      }
      final digit = int.parse(character);
      final key = _digitKeys[digit];
      if (key != null) {
        await pointer.tapKey(key);
      }
      if (!_isTutorialActive(token)) {
        return;
      }
      _onDigit(digit);
      await Future<void>.delayed(const Duration(milliseconds: 220));
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _onDigit(int digit) {
    if (!_isAcceptingInput) {
      return;
    }

    final notifier = ref.read(cubeCountProvider.notifier);
    notifier.appendDigit(digit);

    final state = ref.read(cubeCountProvider);
    if (state.userInput.length >= state.requiredDigitCount) {
      _evaluateAnswer(int.parse(state.userInput));
    }
  }

  void _onClear() {
    if (!_isAcceptingInput) {
      return;
    }
    ref.read(cubeCountProvider.notifier).clearLastDigit();
  }

  Future<void> _evaluateAnswer(int entered) async {
    if (!_isAcceptingInput) {
      return;
    }

    final puzzleState = ref.read(cubeCountProvider);
    final isCorrect = entered == puzzleState.expectedTotal;
    final cubeNotifier = ref.read(cubeCountProvider.notifier);

    setState(() {
      _isAcceptingInput = false;
      _feedback =
          isCorrect ? _AnswerFeedback.correct : _AnswerFeedback.incorrect;
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
      cubeNotifier.signalSuccess();
    } else {
      HapticFeedback.heavyImpact();
      cubeNotifier.signalError();
    }

    ref
        .read(gameSessionProvider.notifier)
        .addScore(isCorrect ? correctPoints : incorrectPenalty);

    await Future<void>.delayed(feedbackDelay);
    if (!mounted) {
      return;
    }

    if (isCorrect) {
      cubeNotifier.onCorrect();
    } else {
      cubeNotifier.onIncorrect();
    }

    setState(() {
      _feedback = _AnswerFeedback.none;
      // Keep the pad locked until the next puzzle's drop finishes.
      _isAcceptingInput = false;
    });
  }

  void _onDropComplete() {
    if (!mounted || _feedback != _AnswerFeedback.none) {
      return;
    }
    setState(() => _isAcceptingInput = true);
  }

  @override
  Widget build(BuildContext context) {
    final currentGrid = ref.watch(
      cubeCountProvider.select((state) => state.currentGrid),
    );
    final input = ref.watch(
      cubeCountProvider.select((state) => state.userInput),
    );
    final successToken = ref.watch(
      cubeCountProvider.select((state) => state.successToken),
    );
    final errorToken = ref.watch(
      cubeCountProvider.select((state) => state.errorToken),
    );

    final answerDisplay = Text(
      input.isEmpty ? '?' : input,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: switch (_feedback) {
              _AnswerFeedback.correct => AppColors.correct,
              _AnswerFeedback.incorrect => AppColors.incorrect,
              _AnswerFeedback.none => AppColors.accent,
            },
            fontWeight: FontWeight.w800,
          ),
    );

    return Scaffold(
      backgroundColor: GameScreenBackground.scaffoldColorFor(
        GameBackgroundStyle.cubeOrange,
      ),
      body: GameScreenBackground(
        style: GameBackgroundStyle.cubeOrange,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (!widget.isTutorial) ...[
                  const GameHud(isOnLightBackground: true),
                  const SizedBox(height: AppSpacing.md),
                ],
                Expanded(
                  flex: widget.isTutorial ? 5 : 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRect(
                          child: IsometricCubeBoard(
                            puzzle: currentGrid,
                            onDropComplete: _onDropComplete,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AnswerFeedbackBurst(
                        successToken: successToken,
                        errorToken: errorToken,
                        contentKey: Object.hash(
                          currentGrid.expectedTotal,
                          currentGrid.hashCode,
                        ),
                        points: correctPoints,
                        penalty: incorrectPenalty,
                        child: answerDisplay,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  flex: widget.isTutorial ? 4 : 5,
                  child: NumberPad(
                    enabled: _isAcceptingInput,
                    onDigit: _onDigit,
                    onClear: _onClear,
                    digitKeys: widget.isTutorial ? _digitKeys : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
