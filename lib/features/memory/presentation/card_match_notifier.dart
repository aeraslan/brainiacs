import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/game_session_notifier.dart';
import '../domain/memory_card.dart';

enum CardMatchPhase {
  memorize,
  play,
}

class CardMatchState {
  const CardMatchState({
    required this.currentLevel,
    required this.cards,
    required this.phase,
    required this.selectedCardIndices,
    required this.isEvaluating,
    required this.mismatchToken,
    required this.mismatchCardIndices,
  });

  factory CardMatchState.initial() {
    return CardMatchState(
      currentLevel: 1,
      cards: const [],
      phase: CardMatchPhase.memorize,
      selectedCardIndices: const [],
      isEvaluating: false,
      mismatchToken: 0,
      mismatchCardIndices: const [],
    );
  }

  static const int maxPairCount = 8;
  static const int matchPoints = 50;
  static const int mismatchPenalty = -20;
  static const Duration memorizeDuration = Duration(seconds: 2);
  static const Duration mismatchDelay = Duration(milliseconds: 500);
  static const Duration levelCompleteDelay = Duration(milliseconds: 600);

  final int currentLevel;
  final List<MemoryCard> cards;
  final CardMatchPhase phase;
  final List<int> selectedCardIndices;
  final bool isEvaluating;
  final int mismatchToken;
  final List<int> mismatchCardIndices;

  int get pairCount => (currentLevel + 1).clamp(1, maxPairCount);

  bool get allMatched =>
      cards.isNotEmpty && cards.every((card) => card.isMatched);

  CardMatchState copyWith({
    int? currentLevel,
    List<MemoryCard>? cards,
    CardMatchPhase? phase,
    List<int>? selectedCardIndices,
    bool? isEvaluating,
    int? mismatchToken,
    List<int>? mismatchCardIndices,
  }) {
    return CardMatchState(
      currentLevel: currentLevel ?? this.currentLevel,
      cards: cards ?? this.cards,
      phase: phase ?? this.phase,
      selectedCardIndices: selectedCardIndices ?? this.selectedCardIndices,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      mismatchToken: mismatchToken ?? this.mismatchToken,
      mismatchCardIndices:
          mismatchCardIndices ?? this.mismatchCardIndices,
    );
  }
}

class CardMatchNotifier extends Notifier<CardMatchState> {
  Timer? _memorizeTimer;
  int _evaluationGeneration = 0;

  @override
  CardMatchState build() {
    ref.onDispose(_cancelMemorizeTimer);
    return CardMatchState.initial();
  }

  void reset() {
    _cancelMemorizeTimer();
    _evaluationGeneration++;
    startLevel(1);
  }

  void startLevel(int level) {
    _cancelMemorizeTimer();
    _evaluationGeneration++;

    final safeLevel = level < 1 ? 1 : level;
    final pairCount = (safeLevel + 1).clamp(1, CardMatchState.maxPairCount);
    final cards = MemoryCardDeck.deal(pairCount: pairCount)
        .map((card) => card.copyWith(isFaceUp: true))
        .toList(growable: false);

    state = CardMatchState(
      currentLevel: safeLevel,
      cards: cards,
      phase: CardMatchPhase.memorize,
      selectedCardIndices: const [],
      isEvaluating: false,
      mismatchToken: 0,
      mismatchCardIndices: const [],
    );

    _memorizeTimer = Timer(CardMatchState.memorizeDuration, endMemorize);
  }

  void skipMemorize() {
    if (state.phase != CardMatchPhase.memorize) {
      return;
    }
    endMemorize();
  }

  void endMemorize() {
    if (state.phase != CardMatchPhase.memorize) {
      return;
    }

    _cancelMemorizeTimer();
    state = state.copyWith(
      phase: CardMatchPhase.play,
      cards: [
        for (final card in state.cards)
          card.copyWith(isFaceUp: card.isMatched),
      ],
    );
  }

  void onCardTapped(int index) {
    if (state.phase == CardMatchPhase.memorize) {
      endMemorize();
    }

    if (state.phase != CardMatchPhase.play ||
        state.isEvaluating ||
        index < 0 ||
        index >= state.cards.length) {
      return;
    }

    final tappedCard = state.cards[index];
    if (tappedCard.isMatched || tappedCard.isFaceUp) {
      return;
    }

    if (state.selectedCardIndices.contains(index)) {
      return;
    }

    final nextSelection = [...state.selectedCardIndices, index];
    final nextCards = List<MemoryCard>.from(state.cards);
    nextCards[index] = tappedCard.copyWith(isFaceUp: true);

    state = state.copyWith(
      cards: nextCards,
      selectedCardIndices: nextSelection,
    );

    if (nextSelection.length == 2) {
      _evaluateSelection(nextSelection);
    }
  }

  Future<void> _evaluateSelection(List<int> selectedIndices) async {
    state = state.copyWith(isEvaluating: true);
    final generation = ++_evaluationGeneration;

    final firstIndex = selectedIndices[0];
    final secondIndex = selectedIndices[1];
    final firstCard = state.cards[firstIndex];
    final secondCard = state.cards[secondIndex];
    final isMatch = firstCard.pairId == secondCard.pairId;

    if (isMatch) {
      ref.read(gameSessionProvider.notifier).addScore(CardMatchState.matchPoints);

      final matchedCards = List<MemoryCard>.from(state.cards);
      matchedCards[firstIndex] =
          firstCard.copyWith(isFaceUp: true, isMatched: true);
      matchedCards[secondIndex] =
          secondCard.copyWith(isFaceUp: true, isMatched: true);

      state = state.copyWith(
        cards: matchedCards,
        selectedCardIndices: const [],
        isEvaluating: false,
      );

      if (state.allMatched) {
        await Future<void>.delayed(CardMatchState.levelCompleteDelay);
        if (generation != _evaluationGeneration) {
          return;
        }
        startLevel(state.currentLevel + 1);
      }
      return;
    }

    ref
        .read(gameSessionProvider.notifier)
        .addScore(CardMatchState.mismatchPenalty);

    state = state.copyWith(
      mismatchToken: state.mismatchToken + 1,
      mismatchCardIndices: List<int>.from(selectedIndices),
    );

    await Future<void>.delayed(CardMatchState.mismatchDelay);
    if (generation != _evaluationGeneration) {
      return;
    }

    final resetCards = List<MemoryCard>.from(state.cards);
    resetCards[firstIndex] = resetCards[firstIndex].copyWith(isFaceUp: false);
    resetCards[secondIndex] =
        resetCards[secondIndex].copyWith(isFaceUp: false);

    state = state.copyWith(
      cards: resetCards,
      selectedCardIndices: const [],
      isEvaluating: false,
      mismatchCardIndices: const [],
    );
  }

  void _cancelMemorizeTimer() {
    _memorizeTimer?.cancel();
    _memorizeTimer = null;
  }
}

final cardMatchProvider =
    NotifierProvider<CardMatchNotifier, CardMatchState>(
  CardMatchNotifier.new,
);
