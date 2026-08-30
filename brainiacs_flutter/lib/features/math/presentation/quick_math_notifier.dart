import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/math_equation.dart';

class QuickMathState {
  const QuickMathState({
    required this.equation,
    required this.currentLevel,
  });

  factory QuickMathState.initial() {
    return QuickMathState(
      currentLevel: 1,
      equation: MathEquation.forLevel(1),
    );
  }

  final MathEquation equation;
  final int currentLevel;

  QuickMathState copyWith({
    MathEquation? equation,
    int? currentLevel,
  }) {
    return QuickMathState(
      equation: equation ?? this.equation,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}

class QuickMathNotifier extends Notifier<QuickMathState> {
  @override
  QuickMathState build() => QuickMathState.initial();

  void reset() {
    state = QuickMathState.initial();
  }

  void onCorrect() {
    final nextLevel = state.currentLevel + 1;
    state = QuickMathState(
      currentLevel: nextLevel,
      equation: MathEquation.forLevel(nextLevel),
    );
  }

  void onIncorrect() {
    state = state.copyWith(
      equation: MathEquation.forLevel(state.currentLevel),
    );
  }
}

final quickMathProvider =
    NotifierProvider<QuickMathNotifier, QuickMathState>(
  QuickMathNotifier.new,
);
