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
import 'balance_logic_notifier.dart';
import 'widgets/balance_board.dart';
import 'widgets/object_pad.dart';

class BalanceLogicScreen extends ConsumerStatefulWidget {
  const BalanceLogicScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<BalanceLogicScreen> createState() => _BalanceLogicScreenState();
}

class _BalanceLogicScreenState extends ConsumerState<BalanceLogicScreen> {
  bool _isAcceptingInput = true;
  String? _selectedObjectId;
  ObjectPadFeedback _feedback = ObjectPadFeedback.none;

  static const int correctPoints = 100;
  static const int incorrectPenalty = -20;
  static const Duration feedbackDelay = Duration(milliseconds: 500);

  final Map<String, GlobalKey> _choiceKeys = {};
  int _tutorialToken = 0;

  GlobalKey _keyFor(String objectId) {
    return _choiceKeys.putIfAbsent(objectId, GlobalKey.new);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(balanceLogicProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(BalanceLogicScreen oldWidget) {
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
        final puzzle = ref.read(balanceLogicProvider).puzzle;
        final key = _choiceKeys[puzzle.correctObjectId];
        return key?.currentContext != null;
      },
      isActive: () => _isTutorialActive(token),
    );

    while (_isTutorialActive(token)) {
      await _playAnswer(correct: true, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!_isTutorialActive(token)) {
        return;
      }
      await _playAnswer(correct: false, token: token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
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
      () => _isAcceptingInput,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    final puzzle = ref.read(balanceLogicProvider).puzzle;
    final objectId = correct
        ? puzzle.correctObjectId
        : puzzle.choices.firstWhere(
            (c) => c != puzzle.correctObjectId,
            orElse: () => puzzle.choices.first,
          );

    final key = _keyFor(objectId);
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
    await _evaluateAnswer(objectId);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _evaluateAnswer(String selected) async {
    if (!_isAcceptingInput) {
      return;
    }

    final puzzle = ref.read(balanceLogicProvider).puzzle;
    final isCorrect = selected == puzzle.correctObjectId;
    final notifier = ref.read(balanceLogicProvider.notifier);

    setState(() {
      _isAcceptingInput = false;
      _selectedObjectId = selected;
      _feedback = isCorrect
          ? ObjectPadFeedback.correct
          : ObjectPadFeedback.incorrect;
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
      _selectedObjectId = null;
      _feedback = ObjectPadFeedback.none;
      _isAcceptingInput = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = ref.watch(
      balanceLogicProvider.select((state) => state.puzzle),
    );
    final successToken = ref.watch(
      balanceLogicProvider.select((state) => state.successToken),
    );
    final errorToken = ref.watch(
      balanceLogicProvider.select((state) => state.errorToken),
    );

    final choiceKeys = widget.isTutorial
        ? {for (final id in puzzle.choices) id: _keyFor(id)}
        : null;

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
                  // Board needs the larger share so L3/L4 trees (3 scales) fit
                  // under the HUD without clipping tilted pans.
                  flex: 5,
                  child: AnswerFeedbackBurst(
                    successToken: successToken,
                    errorToken: errorToken,
                    contentKey: puzzle.identityKey.hashCode,
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
                    child: BalanceBoard(puzzle: puzzle),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  flex: 4,
                  child: ObjectPad(
                    choices: puzzle.choices,
                    enabled: _isAcceptingInput,
                    selectedObjectId: _selectedObjectId,
                    feedback: _feedback,
                    choiceKeys: choiceKeys,
                    onSelected: _evaluateAnswer,
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
