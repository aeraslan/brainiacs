import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/answer_feedback_burst.dart';
import '../domain/math_equation.dart';
import '../domain/missing_operator_equation.dart';
import 'missing_operator_notifier.dart';
import 'widgets/math_game_scaffold.dart';
import 'widgets/operator_pad.dart';

enum _AnswerFeedback { none, correct, incorrect }

class MissingOperatorScreen extends ConsumerStatefulWidget {
  const MissingOperatorScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<MissingOperatorScreen> createState() =>
      _MissingOperatorScreenState();
}

class _MissingOperatorScreenState extends ConsumerState<MissingOperatorScreen> {
  bool _isAcceptingInput = true;
  MathOperator? _selectedOperator;
  _AnswerFeedback _feedback = _AnswerFeedback.none;

  static const int correctPoints = 100;
  static const int incorrectPenalty = -20;
  static const Duration feedbackDelay = Duration(milliseconds: 500);

  final Map<MathOperator, GlobalKey> _operatorKeys = {
    for (final op in MathOperator.values) op: GlobalKey(),
  };
  int _tutorialToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(missingOperatorProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(MissingOperatorScreen oldWidget) {
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
      () => _operatorKeys[MathOperator.add]?.currentContext != null,
      isActive: () => _isTutorialActive(token),
    );

    while (_isTutorialActive(token)) {
      await _playOperatorAnswer(correct: true, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!_isTutorialActive(token)) {
        return;
      }
      await _playOperatorAnswer(correct: false, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  Future<void> _playOperatorAnswer({
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

    final equation = ref.read(missingOperatorProvider).equation;
    final operator = correct
        ? equation.correctOperator
        : _wrongOperator(equation.correctOperator);

    final key = _operatorKeys[operator];
    if (key != null) {
      await pointer.tapKey(key);
    }
    if (!_isTutorialActive(token)) {
      return;
    }
    await _evaluateAnswer(operator);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  MathOperator _wrongOperator(MathOperator correct) {
    for (final op in MathOperator.values) {
      if (op != correct) {
        return op;
      }
    }
    return MathOperator.subtract;
  }

  Future<void> _evaluateAnswer(MathOperator selected) async {
    if (!_isAcceptingInput) {
      return;
    }

    final equation = ref.read(missingOperatorProvider).equation;
    final isCorrect = equation.isCorrect(selected);
    final notifier = ref.read(missingOperatorProvider.notifier);

    setState(() {
      _isAcceptingInput = false;
      _selectedOperator = selected;
      _feedback = isCorrect
          ? _AnswerFeedback.correct
          : _AnswerFeedback.incorrect;
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
      notifier.signalSuccess();
    } else {
      HapticFeedback.heavyImpact();
      notifier.signalError();
    }

    ref
        .read(gameSessionProvider.notifier)
        .addScore(isCorrect ? correctPoints : incorrectPenalty);

    await Future<void>.delayed(feedbackDelay);
    if (!mounted) {
      return;
    }

    if (isCorrect) {
      notifier.onCorrect();
    } else {
      notifier.onIncorrect();
    }
    setState(() {
      _selectedOperator = null;
      _feedback = _AnswerFeedback.none;
      _isAcceptingInput = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final equation = ref.watch(
      missingOperatorProvider.select((state) => state.equation),
    );
    final successToken = ref.watch(
      missingOperatorProvider.select((state) => state.successToken),
    );
    final errorToken = ref.watch(
      missingOperatorProvider.select((state) => state.errorToken),
    );

    final equationDisplay = SizedBox(
      width: double.infinity,
      height: 88,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: _MissingOperatorEquationView(
          equation: equation,
          selectedOperator: _selectedOperator,
          feedback: _feedback,
        ),
      ),
    );

    return MathGameScaffold(
      isTutorial: widget.isTutorial,
      board: AnswerFeedbackBurst(
        successToken: successToken,
        errorToken: errorToken,
        contentKey: equation.identityKey,
        points: correctPoints,
        penalty: incorrectPenalty,
        child: equationDisplay,
      ),
      controls: OperatorPad(
        enabled: _isAcceptingInput,
        onOperator: _evaluateAnswer,
        operatorKeys: widget.isTutorial ? _operatorKeys : null,
      ),
    );
  }
}

class _MissingOperatorEquationView extends StatelessWidget {
  const _MissingOperatorEquationView({
    required this.equation,
    required this.selectedOperator,
    required this.feedback,
  });

  final MissingOperatorEquation equation;
  final MathOperator? selectedOperator;
  final _AnswerFeedback feedback;

  static const TextStyle _fallbackStyle = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.textPrimary,
  );

  TextStyle _baseStyle(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
        ) ??
        _fallbackStyle;
  }

  @override
  Widget build(BuildContext context) {
    final style = _baseStyle(context);
    final known = equation.knownOperator;
    final c = equation.c;

    Widget glyph(String value) => _EquationGlyph(value, style: style);

    Widget slot() => _MissingSlot(
      selectedOperator: selectedOperator,
      feedback: feedback,
      style: style,
    );

    final children = <Widget>[];

    switch (equation.layout) {
      case MissingOperatorLayout.binary:
        children.addAll([
          glyph('${equation.a}'),
          slot(),
          glyph('${equation.b}'),
        ]);
      case MissingOperatorLayout.parenMissingLeft:
        children.addAll([
          glyph('('),
          glyph('${equation.a}'),
          slot(),
          glyph('${equation.b}'),
          glyph(')'),
          glyph(' ${known!.symbol} '),
          glyph('$c'),
        ]);
      case MissingOperatorLayout.parenMissingRight:
        children.addAll([
          glyph('${equation.a}'),
          glyph(' ${known!.symbol} '),
          glyph('('),
          glyph('${equation.b}'),
          slot(),
          glyph('$c'),
          glyph(')'),
        ]);
    }

    children.addAll([glyph(' = '), glyph('${equation.result}')]);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _EquationGlyph extends StatelessWidget {
  const _EquationGlyph(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 56;
    return SizedBox(
      height: fontSize,
      child: Center(
        child: Text(
          text,
          style: style,
          strutStyle: StrutStyle(
            fontSize: fontSize,
            height: 1,
            leading: 0,
            forceStrutHeight: true,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
  }
}

class _MissingSlot extends StatelessWidget {
  const _MissingSlot({
    required this.selectedOperator,
    required this.feedback,
    required this.style,
  });

  final MathOperator? selectedOperator;
  final _AnswerFeedback feedback;
  final TextStyle style;

  Color get _borderColor {
    return switch (feedback) {
      _AnswerFeedback.correct => AppColors.correct,
      _AnswerFeedback.incorrect => AppColors.incorrect,
      _AnswerFeedback.none => AppColors.accent,
    };
  }

  Color get _fillColor {
    return switch (feedback) {
      _AnswerFeedback.correct => AppColors.correct.withValues(alpha: 0.18),
      _AnswerFeedback.incorrect => AppColors.incorrect.withValues(alpha: 0.18),
      _AnswerFeedback.none => AppColors.accent.withValues(alpha: 0.12),
    };
  }

  Color get _textColor {
    return switch (feedback) {
      _AnswerFeedback.correct => AppColors.correct,
      _AnswerFeedback.incorrect => AppColors.incorrect,
      _AnswerFeedback.none => AppColors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 56;
    final symbol = selectedOperator?.symbol ?? '?';
    final box = SizedBox(
      height: fontSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _fillColor,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: _borderColor, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Center(
            child: Text(
              symbol,
              style: style.copyWith(color: _textColor),
              strutStyle: StrutStyle(
                fontSize: fontSize,
                height: 1,
                leading: 0,
                forceStrutHeight: true,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ),
        ),
      ),
    );

    final spaced = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: selectedOperator != null
          ? box
          : box
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  alignment: Alignment.center,
                  duration: 700.ms,
                  curve: Curves.easeInOut,
                ),
    );

    return spaced;
  }
}
