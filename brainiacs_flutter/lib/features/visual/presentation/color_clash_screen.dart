import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/animated_orbital_rings.dart';
import '../../../shared/widgets/answer_feedback_burst.dart';
import '../../../shared/widgets/game_hud.dart';
import 'color_clash_notifier.dart';
import 'visual_colors.dart';
import 'widgets/stroop_choice_pad.dart';
import 'widgets/stroop_rule_pill.dart';
import 'widgets/stroop_target_word.dart';

class ColorClashScreen extends ConsumerStatefulWidget {
  const ColorClashScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<ColorClashScreen> createState() => _ColorClashScreenState();
}

class _ColorClashScreenState extends ConsumerState<ColorClashScreen> {
  bool _isAcceptingInput = true;
  String? _selectedIdentityId;
  StroopPadFeedback _feedback = StroopPadFeedback.none;
  bool _emphasizeRule = false;
  String? _hintIdentityId;

  static const int correctPoints = 100;
  static const int incorrectPenalty = -20;
  static const Duration feedbackDelay = Duration(milliseconds: 500);
  static const Duration questionPause = Duration(milliseconds: 900);
  static const Duration ruleEmphasizeDuration = Duration(milliseconds: 1200);
  static const Duration postCorrectBeat = Duration(milliseconds: 700);
  static const Duration correctHintDuration = Duration(milliseconds: 1200);

  final Map<String, GlobalKey> _choiceKeys = {};
  int _tutorialToken = 0;

  GlobalKey _keyFor(String identityId) {
    return _choiceKeys.putIfAbsent(identityId, GlobalKey.new);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(colorClashProvider.notifier).reset(
            isTutorial: widget.isTutorial,
          );
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(ColorClashScreen oldWidget) {
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
      () {
        final round = ref.read(colorClashProvider).round;
        final key = _choiceKeys[round.correctIdentityId];
        return key?.currentContext != null;
      },
      isActive: () => _isTutorialActive(token),
    );

    while (_isTutorialActive(token)) {
      await _playAnswer(correct: true, token: token);
      if (!_isTutorialActive(token)) {
        return;
      }
      await _playAnswer(correct: false, token: token);
    }
  }

  Future<void> _playAnswer({
    required bool correct,
    required int token,
  }) async {
    final pointer = widget.pointerController;
    if (pointer == null || !_isTutorialActive(token)) {
      return;
    }

    await waitUntil(
      () => _isAcceptingInput && _hintIdentityId == null,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    // Pause on the question so the player can read the target word.
    await Future<void>.delayed(questionPause);
    if (!_isTutorialActive(token)) {
      return;
    }

    // Emphasize the rule pill before answering.
    setState(() => _emphasizeRule = true);
    await Future<void>.delayed(ruleEmphasizeDuration);
    if (!_isTutorialActive(token)) {
      return;
    }
    setState(() => _emphasizeRule = false);

    final round = ref.read(colorClashProvider).round;
    final identityId = correct
        ? round.correctIdentityId
        : round.choices
            .firstWhere(
              (c) => c.identityId != round.correctIdentityId,
              orElse: () => round.choices.first,
            )
            .identityId;

    final key = _keyFor(identityId);
    await waitUntil(
      () => key.currentContext != null,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    await pointer.tapKey(key);
    if (!_isTutorialActive(token)) {
      return;
    }

    await _evaluateAnswer(
      identityId,
      delayIncorrectAdvance: !correct,
    );

    if (!_isTutorialActive(token)) {
      return;
    }

    if (correct) {
      await Future<void>.delayed(postCorrectBeat);
    }
  }

  Future<void> _evaluateAnswer(
    String selected, {
    bool delayIncorrectAdvance = false,
  }) async {
    if (!_isAcceptingInput) {
      return;
    }

    final round = ref.read(colorClashProvider).round;
    final isCorrect = round.isCorrect(selected);
    final notifier = ref.read(colorClashProvider.notifier);
    final correctId = round.correctIdentityId;

    setState(() {
      _isAcceptingInput = false;
      _selectedIdentityId = selected;
      _feedback = isCorrect
          ? StroopPadFeedback.correct
          : StroopPadFeedback.incorrect;
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
      setState(() {
        _selectedIdentityId = null;
        _feedback = StroopPadFeedback.none;
        _hintIdentityId = null;
        _isAcceptingInput = true;
      });
      return;
    }

    // Wrong answer: optionally teach by highlighting the correct option
    // before advancing to the next round.
    if (delayIncorrectAdvance) {
      setState(() => _hintIdentityId = correctId);
      await Future<void>.delayed(correctHintDuration);
      if (!mounted) {
        return;
      }
    }

    notifier.onIncorrect();
    setState(() {
      _selectedIdentityId = null;
      _feedback = StroopPadFeedback.none;
      _hintIdentityId = null;
      _isAcceptingInput = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final round = ref.watch(
      colorClashProvider.select((state) => state.round),
    );
    final successToken = ref.watch(
      colorClashProvider.select((state) => state.successToken),
    );
    final errorToken = ref.watch(
      colorClashProvider.select((state) => state.errorToken),
    );

    final choiceKeys = widget.isTutorial
        ? {for (final c in round.choices) c.identityId: _keyFor(c.identityId)}
        : null;

    return Scaffold(
      backgroundColor: VisualColors.sky,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedOrbitalRings(ringColor: VisualColors.ring),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  if (!widget.isTutorial) ...[
                    const GameHud(isOnLightBackground: true),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  StroopRulePill(
                    rule: round.rule,
                    emphasized: _emphasizeRule,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    flex: 4,
                    child: AnswerFeedbackBurst(
                      successToken: successToken,
                      errorToken: errorToken,
                      contentKey: round.identityKey.hashCode,
                      points: correctPoints,
                      penalty: incorrectPenalty,
                      applySuccessEffectsToChild: false,
                      successOverlay: const Icon(
                        Icons.check_rounded,
                        size: 168,
                        color: AppColors.correct,
                        shadows: [
                          Shadow(
                            color: Color(0x66008800),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: StroopTargetWord(round: round)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    flex: 5,
                    child: StroopChoicePad(
                      choices: round.choices,
                      usesTextOptions: round.usesTextOptions,
                      enabled: _isAcceptingInput,
                      selectedIdentityId: _selectedIdentityId,
                      feedback: _feedback,
                      hintIdentityId: _hintIdentityId,
                      choiceKeys: choiceKeys,
                      onSelected: _evaluateAnswer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
