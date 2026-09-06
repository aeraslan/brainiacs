import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/game_hud.dart';
import '../../../shared/widgets/game_screen_background.dart';
import '../../../shared/widgets/number_pad.dart';
import 'quick_math_notifier.dart';

enum _AnswerFeedback { none, correct, incorrect }

class QuickMathScreen extends ConsumerStatefulWidget {
  const QuickMathScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<QuickMathScreen> createState() => _QuickMathScreenState();
}

class _QuickMathScreenState extends ConsumerState<QuickMathScreen> {
  bool _isAcceptingInput = true;
  String _input = '';
  _AnswerFeedback _feedback = _AnswerFeedback.none;
  int _feedbackKey = 0;

  static const int correctPoints = 100;
  static const int incorrectPenalty = -20;
  static const Duration feedbackDelay = Duration(milliseconds: 250);

  final Map<int, GlobalKey> _digitKeys = {
    for (var digit = 0; digit <= 9; digit++) digit: GlobalKey(),
  };
  int _tutorialToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quickMathProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(QuickMathScreen oldWidget) {
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
      await _playMathAnswer(correct: true, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!_isTutorialActive(token)) {
        return;
      }
      await _playMathAnswer(correct: false, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  Future<void> _playMathAnswer({
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

    final equation = ref.read(quickMathProvider).equation;
    final digits = correct
        ? equation.correctAnswer.toString()
        : wrongDigitString(equation.correctAnswer, equation.requiredDigitCount);

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

    final equation = ref.read(quickMathProvider).equation;
    final nextInput = '$_input$digit';

    setState(() {
      _input = nextInput;
    });

    if (nextInput.length >= equation.requiredDigitCount) {
      _evaluateAnswer(int.parse(nextInput));
    }
  }

  void _onClear() {
    if (!_isAcceptingInput || _input.isEmpty) {
      return;
    }

    setState(() {
      _input = _input.substring(0, _input.length - 1);
    });
  }

  Future<void> _evaluateAnswer(int entered) async {
    if (!_isAcceptingInput) {
      return;
    }

    final equation = ref.read(quickMathProvider).equation;
    final isCorrect = entered == equation.correctAnswer;

    setState(() {
      _isAcceptingInput = false;
      _feedback = isCorrect
          ? _AnswerFeedback.correct
          : _AnswerFeedback.incorrect;
      _feedbackKey++;
    });

    ref
        .read(gameSessionProvider.notifier)
        .addScore(isCorrect ? correctPoints : incorrectPenalty);

    await Future<void>.delayed(feedbackDelay);
    if (!mounted) {
      return;
    }

    if (isCorrect) {
      ref.read(quickMathProvider.notifier).onCorrect();
    } else {
      ref.read(quickMathProvider.notifier).onIncorrect();
    }
    setState(() {
      _input = '';
      _feedback = _AnswerFeedback.none;
      _isAcceptingInput = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final equation = ref.watch(
      quickMathProvider.select((state) => state.equation),
    );

    Widget equationDisplay = SizedBox(
      width: double.infinity,
      height: 64,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: RichText(
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          text: TextSpan(
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
            children: [
              TextSpan(text: '${equation.displayText} '),
              TextSpan(
                text: _input.isEmpty ? '?' : _input,
                style: TextStyle(
                  color: switch (_feedback) {
                    _AnswerFeedback.correct => AppColors.correct,
                    _AnswerFeedback.incorrect => AppColors.incorrect,
                    _AnswerFeedback.none => AppColors.accent,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_feedback == _AnswerFeedback.correct) {
      equationDisplay = equationDisplay
          .animate(key: ValueKey(_feedbackKey))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.06, 1.06),
            duration: 120.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.06, 1.06),
            end: const Offset(1, 1),
            duration: 120.ms,
          )
          .tint(color: AppColors.correct, duration: 200.ms);
    } else if (_feedback == _AnswerFeedback.incorrect) {
      equationDisplay = equationDisplay
          .animate(key: ValueKey(_feedbackKey))
          .shakeX(amount: 8, duration: 250.ms, hz: 6);
    }

    return Scaffold(
      backgroundColor: GameScreenBackground.scaffoldColorFor(
        GameBackgroundStyle.mathYellow,
      ),
      body: GameScreenBackground(
        style: GameBackgroundStyle.mathYellow,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (!widget.isTutorial)
                  const GameHud(isOnLightBackground: true),
                const Spacer(),
                equationDisplay,
                const Spacer(),
                Expanded(
                  flex: 5,
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
