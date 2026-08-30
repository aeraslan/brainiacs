import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/game_hud.dart';
import '../../../shared/widgets/game_screen_background.dart';
import 'card_match_notifier.dart';
import 'widgets/card_match_board.dart';

class CardMatchScreen extends ConsumerStatefulWidget {
  const CardMatchScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<CardMatchScreen> createState() => _CardMatchScreenState();
}

class _CardMatchScreenState extends ConsumerState<CardMatchScreen> {
  final List<GlobalKey> _cardKeys = [];
  int _tutorialToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardMatchProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(CardMatchScreen oldWidget) {
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

  void _ensureCardKeys(int count) {
    if (_cardKeys.length == count) {
      return;
    }
    _cardKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(count, (_) => GlobalKey()));
  }

  bool _isTutorialActive(int token) {
    return mounted &&
        token == _tutorialToken &&
        widget.isTutorial &&
        widget.autoPlay;
  }

  Future<void> _runTutorial() async {
    final token = ++_tutorialToken;
    final pointer = widget.pointerController;
    if (pointer == null) {
      return;
    }

    await waitUntil(
      () => ref.read(cardMatchProvider).cards.isNotEmpty,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!_isTutorialActive(token)) {
      return;
    }
    ref.read(cardMatchProvider.notifier).skipMemorize();

    await waitUntil(
      () => ref.read(cardMatchProvider).phase == CardMatchPhase.play,
      isActive: () => _isTutorialActive(token),
    );

    while (_isTutorialActive(token)) {
      if (ref.read(cardMatchProvider).phase == CardMatchPhase.memorize) {
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        if (!_isTutorialActive(token)) {
          return;
        }
        ref.read(cardMatchProvider.notifier).skipMemorize();
      }

      await waitUntil(
        () =>
            !ref.read(cardMatchProvider).isEvaluating &&
            ref.read(cardMatchProvider).phase == CardMatchPhase.play,
        isActive: () => _isTutorialActive(token),
      );
      if (!_isTutorialActive(token)) {
        return;
      }

      final mismatch = _findPair(matching: false);
      if (mismatch != null) {
        await _tapCard(mismatch.$1, token);
        await _tapCard(mismatch.$2, token);
        await Future<void>.delayed(CardMatchState.mismatchDelay);
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }

      if (!_isTutorialActive(token)) {
        return;
      }

      await waitUntil(
        () => !ref.read(cardMatchProvider).isEvaluating,
        isActive: () => _isTutorialActive(token),
      );

      final match = _findPair(matching: true);
      if (match != null) {
        await _tapCard(match.$1, token);
        await _tapCard(match.$2, token);
        await Future<void>.delayed(const Duration(milliseconds: 800));
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
  }

  (int, int)? _findPair({required bool matching}) {
    final cards = ref.read(cardMatchProvider).cards;
    for (var first = 0; first < cards.length; first++) {
      if (cards[first].isMatched || cards[first].isFaceUp) {
        continue;
      }
      for (var second = first + 1; second < cards.length; second++) {
        if (cards[second].isMatched || cards[second].isFaceUp) {
          continue;
        }
        final isMatch = cards[first].pairId == cards[second].pairId;
        if (isMatch == matching) {
          return (first, second);
        }
      }
    }
    return null;
  }

  Future<void> _tapCard(int index, int token) async {
    final pointer = widget.pointerController;
    if (pointer == null || !_isTutorialActive(token)) {
      return;
    }
    if (index < 0 || index >= _cardKeys.length) {
      return;
    }

    await pointer.tapKey(_cardKeys[index]);
    if (!_isTutorialActive(token)) {
      return;
    }
    _onCardTapped(index);
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  void _onBackgroundTap() {
    ref.read(cardMatchProvider.notifier).skipMemorize();
  }

  void _onCardTapped(int index) {
    ref.read(cardMatchProvider.notifier).onCardTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(cardMatchProvider);
    _ensureCardKeys(matchState.cards.length);

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
                Text(
                  'Level ${matchState.currentLevel}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: matchState.phase == CardMatchPhase.memorize
                        ? _onBackgroundTap
                        : null,
                    child: Center(
                      child: CardMatchBoard(
                        cards: matchState.cards,
                        phase: matchState.phase,
                        selectedCardIndices: matchState.selectedCardIndices,
                        isEvaluating: matchState.isEvaluating,
                        mismatchToken: matchState.mismatchToken,
                        mismatchCardIndices: matchState.mismatchCardIndices,
                        onCardTapped: _onCardTapped,
                        cardKeys: widget.isTutorial ? _cardKeys : null,
                      ),
                    ),
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
