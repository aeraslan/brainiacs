import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cube_puzzle.dart';

class CubeCountState {
  const CubeCountState({
    required this.currentGrid,
    required this.userInput,
    required this.currentLevel,
  });

  factory CubeCountState.initial() {
    final puzzle = CubePuzzle.generate(1);
    return CubeCountState(
      currentGrid: puzzle,
      userInput: '',
      currentLevel: 1,
    );
  }

  final CubePuzzle currentGrid;
  final String userInput;
  final int currentLevel;

  int get expectedTotal => currentGrid.expectedTotal;

  int get requiredDigitCount => currentGrid.requiredDigitCount;

  CubeCountState copyWith({
    CubePuzzle? currentGrid,
    String? userInput,
    int? currentLevel,
  }) {
    return CubeCountState(
      currentGrid: currentGrid ?? this.currentGrid,
      userInput: userInput ?? this.userInput,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}

class CubeCountNotifier extends Notifier<CubeCountState> {
  @override
  CubeCountState build() => CubeCountState.initial();

  void reset() {
    state = CubeCountState.initial();
  }

  void appendDigit(int digit) {
    state = state.copyWith(userInput: '${state.userInput}$digit');
  }

  void clearLastDigit() {
    if (state.userInput.isEmpty) {
      return;
    }
    state = state.copyWith(
      userInput: state.userInput.substring(0, state.userInput.length - 1),
    );
  }

  void onCorrect() {
    final nextLevel = state.currentLevel + 1;
    final puzzle = CubePuzzle.generate(
      nextLevel,
      excluding: state.currentGrid,
    );
    state = CubeCountState(
      currentGrid: puzzle,
      userInput: '',
      currentLevel: nextLevel,
    );
  }

  void onIncorrect() {
    final puzzle = CubePuzzle.generate(
      state.currentLevel,
      excluding: state.currentGrid,
    );
    state = state.copyWith(
      currentGrid: puzzle,
      userInput: '',
    );
  }
}

final cubeCountProvider =
    NotifierProvider<CubeCountNotifier, CubeCountState>(
  CubeCountNotifier.new,
);
