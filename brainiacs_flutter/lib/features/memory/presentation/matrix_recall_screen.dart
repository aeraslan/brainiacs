import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/answer_feedback_burst.dart';
import '../../../shared/widgets/game_hud.dart';
import '../../../shared/widgets/game_screen_background.dart';
import 'matrix_recall_notifier.dart';
import 'widgets/matrix_recall_board.dart';

class MatrixRecallScreen extends ConsumerStatefulWidget {
  const MatrixRecallScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<MatrixRecallScreen> createState() => _MatrixRecallScreenState();
}

class _MatrixRecallScreenState extends ConsumerState<MatrixRecallScreen> {
  final List<GlobalKey> _tileKeys = [];
  final GlobalKey _pointerRestKey = GlobalKey();
  int _tutorialToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matrixRecallProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(MatrixRecallScreen oldWidget) {
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

  void _ensureTileKeys(int count) {
    if (_tileKeys.length == count) {
      return;
    }
    _tileKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(count, (_) => GlobalKey()));
  }

  bool _isTutorialActive(int token) {
    return mounted &&
        token == _tutorialToken &&
        widget.isTutorial &&
        widget.autoPlay;
  }

  Future<void> _parkPointerAwayFromBoard(int token) async {
    final pointer = widget.pointerController;
    if (pointer == null || !_isTutorialActive(token)) {
      return;
    }
    await pointer.moveToKey(_pointerRestKey);
  }

  Future<void> _runTutorial() async {
    final token = ++_tutorialToken;
    final pointer = widget.pointerController;
    if (pointer == null) {
      return;
    }

    await waitUntil(
      () => ref.read(matrixRecallProvider).sequence.isNotEmpty,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    await _parkPointerAwayFromBoard(token);

    while (_isTutorialActive(token)) {
      // Stay off the matrix while the sequence plays.
      await _parkPointerAwayFromBoard(token);

      await waitUntil(
        () =>
            ref.read(matrixRecallProvider).phase == MatrixRecallPhase.play &&
            ref.read(matrixRecallProvider).inputUnlocked,
        isActive: () => _isTutorialActive(token),
      );
      if (!_isTutorialActive(token)) {
        return;
      }

      final sequence = List<int>.from(ref.read(matrixRecallProvider).sequence);
      for (final index in sequence) {
        if (!_isTutorialActive(token)) {
          return;
        }
        await _tapTile(index, token);
      }

      await _parkPointerAwayFromBoard(token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!_isTutorialActive(token)) {
        return;
      }

      await waitUntil(
        () =>
            ref.read(matrixRecallProvider).phase == MatrixRecallPhase.play &&
            ref.read(matrixRecallProvider).inputUnlocked,
        isActive: () => _isTutorialActive(token),
      );
      if (!_isTutorialActive(token)) {
        return;
      }

      final nextSequence = ref.read(matrixRecallProvider).sequence;
      if (nextSequence.isEmpty) {
        continue;
      }
      final wrongIndex = _wrongIndexFor(nextSequence.first);
      await _tapTile(wrongIndex, token);
      await _parkPointerAwayFromBoard(token);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  int _wrongIndexFor(int correct) {
    final tileCount = ref.read(matrixRecallProvider).tileCount;
    return (correct + 1) % tileCount;
  }

  Future<void> _tapTile(int index, int token) async {
    final pointer = widget.pointerController;
    if (pointer == null || !_isTutorialActive(token)) {
      return;
    }
    if (index < 0 || index >= _tileKeys.length) {
      return;
    }

    await pointer.tapKey(_tileKeys[index]);
    if (!_isTutorialActive(token)) {
      return;
    }
    ref.read(matrixRecallProvider.notifier).onTileTapped(index);
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  void _onTileTapped(int index) {
    ref.read(matrixRecallProvider.notifier).onTileTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = ref.watch(
      matrixRecallProvider.select((state) => state.gridSize),
    );
    final litTileIndex = ref.watch(
      matrixRecallProvider.select((state) => state.litTileIndex),
    );
    final wrongTileIndex = ref.watch(
      matrixRecallProvider.select((state) => state.wrongTileIndex),
    );
    final inputUnlocked = ref.watch(
      matrixRecallProvider.select((state) => state.inputUnlocked),
    );
    final shakeToken = ref.watch(
      matrixRecallProvider.select((state) => state.shakeToken),
    );
    final phase = ref.watch(
      matrixRecallProvider.select((state) => state.phase),
    );
    final successToken = ref.watch(
      matrixRecallProvider.select((state) => state.successToken),
    );
    final errorToken = ref.watch(
      matrixRecallProvider.select((state) => state.errorToken),
    );
    final roundToken = ref.watch(
      matrixRecallProvider.select((state) => state.roundToken),
    );

    _ensureTileKeys(gridSize * gridSize);

    return Scaffold(
      backgroundColor: GameScreenBackground.scaffoldColorFor(
        GameBackgroundStyle.memoryGreen,
      ),
      body: GameScreenBackground(
        style: GameBackgroundStyle.memoryGreen,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (!widget.isTutorial) ...[
                  const GameHud(isOnLightBackground: true),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: AnswerFeedbackBurst(
                          successToken: successToken,
                          errorToken: errorToken,
                          contentKey: roundToken,
                          points: MatrixRecallState.correctPoints,
                          penalty: MatrixRecallState.incorrectPenalty,
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
                          child: MatrixRecallBoard(
                            gridSize: gridSize,
                            litTileIndex: litTileIndex,
                            wrongTileIndex: wrongTileIndex,
                            inputUnlocked: inputUnlocked,
                            shakeToken: shakeToken,
                            onTileTapped: _onTileTapped,
                            tileKeys: widget.isTutorial ? _tileKeys : null,
                          ),
                        ),
                      ),
                      if (widget.isTutorial) ...[
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          key: _pointerRestKey,
                          width: AppSpacing.xxl,
                          height: AppSpacing.xxl,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        phase == MatrixRecallPhase.watch
                            ? 'Watch the sequence...'
                            : 'Your turn!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
