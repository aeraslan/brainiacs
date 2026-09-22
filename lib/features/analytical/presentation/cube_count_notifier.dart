import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cube_puzzle.dart';

class CubeCountState {
  const CubeCountState({
    required this.currentGrid,
    required this.userInput,
    required this.currentLevel,
    this.successToken = 0,
    this.errorToken = 0,
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
  final int successToken;
  final int errorToken;

  int get expectedTotal => currentGrid.expectedTotal;

  int get requiredDigitCount => currentGrid.requiredDigitCount;

  CubeCountState copyWith({
    CubePuzzle? currentGrid,
    String? userInput,
    int? currentLevel,
    int? successToken,
    int? errorToken,
  }) {
    return CubeCountState(
      currentGrid: currentGrid ?? this.currentGrid,
      userInput: userInput ?? this.userInput,
      currentLevel: currentLevel ?? this.currentLevel,
      successToken: successToken ?? this.successToken,
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

class CubeCountNotifier extends Notifier<CubeCountState> {
  @override
  CubeCountState build() => CubeCountState.initial();

  void reset() {
    state = CubeCountState.initial();
  }

  void signalSuccess() {
    state = state.copyWith(successToken: state.successToken + 1);
  }

  void signalError() {
    state = state.copyWith(errorToken: state.errorToken + 1);
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
      successToken: state.successToken,
      errorToken: state.errorToken,
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

  /// Discard the current puzzle and generate a new one at the same level.
  void rerollCurrent() {
    onIncorrect();
  }
}

final cubeCountProvider =
    NotifierProvider<CubeCountNotifier, CubeCountState>(
  CubeCountNotifier.new,
);
