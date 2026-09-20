import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/balance_puzzle.dart';

class BalanceLogicState {
  const BalanceLogicState({
    required this.puzzle,
    required this.correctCount,
    this.successToken = 0,
    this.errorToken = 0,
  });

  factory BalanceLogicState.initial() {
    return BalanceLogicState(
      correctCount: 0,
      puzzle: BalancePuzzle.forCorrectCount(0),
    );
  }

  final BalancePuzzle puzzle;
  final int correctCount;
  final int successToken;
  final int errorToken;

  BalanceLogicState copyWith({
    BalancePuzzle? puzzle,
    int? correctCount,
    int? successToken,
    int? errorToken,
  }) {
    return BalanceLogicState(
      puzzle: puzzle ?? this.puzzle,
      correctCount: correctCount ?? this.correctCount,
      successToken: successToken ?? this.successToken,
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

class BalanceLogicNotifier extends Notifier<BalanceLogicState> {
  @override
  BalanceLogicState build() => BalanceLogicState.initial();

  void reset() {
    state = BalanceLogicState.initial();
  }

  void signalSuccess() {
    state = state.copyWith(successToken: state.successToken + 1);
  }

  void signalError() {
    state = state.copyWith(errorToken: state.errorToken + 1);
  }

  void onCorrect() {
    final nextCount = state.correctCount + 1;
    state = BalanceLogicState(
      correctCount: nextCount,
      puzzle: BalancePuzzle.forCorrectCount(
        nextCount,
        excluding: state.puzzle,
      ),
      successToken: state.successToken,
      errorToken: state.errorToken,
    );
  }

  void onIncorrect() {
    state = state.copyWith(
      puzzle: BalancePuzzle.forCorrectCount(
        state.correctCount,
        excluding: state.puzzle,
      ),
    );
  }
}

final balanceLogicProvider =
    NotifierProvider<BalanceLogicNotifier, BalanceLogicState>(
  BalanceLogicNotifier.new,
);
