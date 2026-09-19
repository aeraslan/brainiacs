import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/missing_operator_equation.dart';

class MissingOperatorState {
  const MissingOperatorState({
    required this.equation,
    required this.correctCount,
    this.successToken = 0,
    this.errorToken = 0,
  });

  factory MissingOperatorState.initial() {
    return MissingOperatorState(
      correctCount: 0,
      equation: MissingOperatorEquation.forCorrectCount(0),
    );
  }

  final MissingOperatorEquation equation;
  final int correctCount;
  final int successToken;
  final int errorToken;

  MissingOperatorState copyWith({
    MissingOperatorEquation? equation,
    int? correctCount,
    int? successToken,
    int? errorToken,
  }) {
    return MissingOperatorState(
      equation: equation ?? this.equation,
      correctCount: correctCount ?? this.correctCount,
      successToken: successToken ?? this.successToken,
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

class MissingOperatorNotifier extends Notifier<MissingOperatorState> {
  @override
  MissingOperatorState build() => MissingOperatorState.initial();

  void reset() {
    state = MissingOperatorState.initial();
  }

  void signalSuccess() {
    state = state.copyWith(successToken: state.successToken + 1);
  }

  void signalError() {
    state = state.copyWith(errorToken: state.errorToken + 1);
  }

  void onCorrect() {
    final nextCount = state.correctCount + 1;
    state = MissingOperatorState(
      correctCount: nextCount,
      equation: MissingOperatorEquation.forCorrectCount(nextCount),
      successToken: state.successToken,
      errorToken: state.errorToken,
    );
  }

  void onIncorrect() {
    state = state.copyWith(
      equation: MissingOperatorEquation.forCorrectCount(state.correctCount),
    );
  }
}

final missingOperatorProvider =
    NotifierProvider<MissingOperatorNotifier, MissingOperatorState>(
      MissingOperatorNotifier.new,
    );
