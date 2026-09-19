import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/math_equation.dart';

class QuickMathState {
  const QuickMathState({
    required this.equation,
    required this.currentLevel,
    this.successToken = 0,
    this.errorToken = 0,
  });

  factory QuickMathState.initial() {
    return QuickMathState(currentLevel: 1, equation: MathEquation.forLevel(1));
  }

  final MathEquation equation;
  final int currentLevel;
  final int successToken;
  final int errorToken;

  QuickMathState copyWith({
    MathEquation? equation,
    int? currentLevel,
    int? successToken,
    int? errorToken,
  }) {
    return QuickMathState(
      equation: equation ?? this.equation,
      currentLevel: currentLevel ?? this.currentLevel,
      successToken: successToken ?? this.successToken,
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

class QuickMathNotifier extends Notifier<QuickMathState> {
  @override
  QuickMathState build() => QuickMathState.initial();

  void reset() {
    state = QuickMathState.initial();
  }

  void signalSuccess() {
    state = state.copyWith(successToken: state.successToken + 1);
  }

  void signalError() {
    state = state.copyWith(errorToken: state.errorToken + 1);
  }

  void onCorrect() {
    final nextLevel = state.currentLevel + 1;
    state = QuickMathState(
      currentLevel: nextLevel,
      equation: MathEquation.forLevel(
        nextLevel,
        minDifficultyScore: state.equation.difficultyScore,
      ),
      successToken: state.successToken,
      errorToken: state.errorToken,
    );
  }

  void onIncorrect() {
    state = state.copyWith(
      equation: MathEquation.forLevel(
        state.currentLevel,
        minDifficultyScore: state.equation.difficultyScore,
      ),
    );
  }
}

final quickMathProvider = NotifierProvider<QuickMathNotifier, QuickMathState>(
  QuickMathNotifier.new,
);
