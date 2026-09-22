import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/color_clash_round.dart';

class ColorClashState {
  const ColorClashState({
    required this.round,
    required this.correctCount,
    this.successToken = 0,
    this.errorToken = 0,
  });

  factory ColorClashState.initial() {
    return ColorClashState(
      correctCount: 0,
      round: ColorClashRound.forCorrectCount(0),
    );
  }

  final ColorClashRound round;
  final int correctCount;
  final int successToken;
  final int errorToken;

  ColorClashState copyWith({
    ColorClashRound? round,
    int? correctCount,
    int? successToken,
    int? errorToken,
  }) {
    return ColorClashState(
      round: round ?? this.round,
      correctCount: correctCount ?? this.correctCount,
      successToken: successToken ?? this.successToken,
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

class ColorClashNotifier extends Notifier<ColorClashState> {
  bool _isTutorial = false;
  int _tutorialBeat = 0;

  @override
  ColorClashState build() => ColorClashState.initial();

  void reset({bool isTutorial = false}) {
    _isTutorial = isTutorial;
    _tutorialBeat = 0;
    if (isTutorial) {
      state = ColorClashState(
        correctCount: 0,
        round: ColorClashRound.forTutorialBeat(0),
      );
      return;
    }
    state = ColorClashState.initial();
  }

  void signalSuccess() {
    state = state.copyWith(successToken: state.successToken + 1);
  }

  void signalError() {
    state = state.copyWith(errorToken: state.errorToken + 1);
  }

  void onCorrect() {
    final nextCount = state.correctCount + 1;
    state = ColorClashState(
      correctCount: nextCount,
      round: _nextRound(correctCount: nextCount),
      successToken: state.successToken,
      errorToken: state.errorToken,
    );
  }

  void onIncorrect() {
    state = state.copyWith(
      round: _nextRound(correctCount: state.correctCount),
    );
  }

  /// Discard the current round and generate a new one at the same difficulty.
  void rerollCurrent() {
    onIncorrect();
  }

  ColorClashRound _nextRound({required int correctCount}) {
    if (_isTutorial) {
      _tutorialBeat++;
      return ColorClashRound.forTutorialBeat(
        _tutorialBeat,
        excluding: state.round,
      );
    }
    return ColorClashRound.forCorrectCount(
      correctCount,
      excluding: state.round,
    );
  }
}

final colorClashProvider =
    NotifierProvider<ColorClashNotifier, ColorClashState>(
  ColorClashNotifier.new,
);
