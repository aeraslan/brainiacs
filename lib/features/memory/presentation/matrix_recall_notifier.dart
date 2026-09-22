import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/game_session_notifier.dart';
import '../domain/matrix_recall_sequence.dart';

enum MatrixRecallPhase {
  watch,
  play,
}

class MatrixRecallState {
  const MatrixRecallState({
    required this.phase,
    required this.sequence,
    required this.currentSequenceIndex,
    required this.sequenceLength,
    required this.gridSize,
    this.litTileIndex,
    this.wrongTileIndex,
    this.successToken = 0,
    this.errorToken = 0,
    this.roundToken = 0,
    this.isEvaluating = false,
  });

  factory MatrixRecallState.initial() {
    return const MatrixRecallState(
      phase: MatrixRecallPhase.watch,
      sequence: [],
      currentSequenceIndex: 0,
      sequenceLength: initialSequenceLength,
      gridSize: defaultGridSize,
    );
  }

  static const int defaultGridSize = MatrixRecallSequence.defaultGridSize;
  static const int initialSequenceLength = MatrixRecallSequence.initialLength;
  static const int correctPoints = 40;
  static const int incorrectPenalty = -20;
  /// Length-3 baseline lit duration; see [watchDurationsFor].
  static const Duration tileLitDuration = Duration(milliseconds: 600);
  /// Length-3 baseline gap duration; see [watchDurationsFor].
  static const Duration tileGapDuration = Duration(milliseconds: 200);
  static const int tileLitStepMs = 80;
  static const int tileGapStepMs = 25;
  static const int minTileLitMs = 250;
  static const int minTileGapMs = 80;
  static const Duration feedbackHoldDelay = Duration(milliseconds: 650);
  /// Covers most of [CountdownOverlay.dissolveDuration] so playback starts
  /// after the GO! cover has largely faded.
  static const Duration introDelay = Duration(milliseconds: 1200);
  static const Duration interRoundDelay = Duration(milliseconds: 550);
  static const Duration pausePollInterval = Duration(milliseconds: 50);

  /// Watch Phase lit/gap timings scaled by [sequenceLength].
  ///
  /// Anchored at [initialSequenceLength] (600ms lit / 200ms gap). Each extra
  /// item shortens lit by [tileLitStepMs] and gap by [tileGapStepMs], clamped
  /// to [minTileLitMs] / [minTileGapMs].
  static ({Duration lit, Duration gap}) watchDurationsFor(int sequenceLength) {
    final steps = (sequenceLength - initialSequenceLength).clamp(0, 1 << 30);
    final litMs = (tileLitDuration.inMilliseconds - steps * tileLitStepMs)
        .clamp(minTileLitMs, tileLitDuration.inMilliseconds);
    final gapMs = (tileGapDuration.inMilliseconds - steps * tileGapStepMs)
        .clamp(minTileGapMs, tileGapDuration.inMilliseconds);
    return (
      lit: Duration(milliseconds: litMs),
      gap: Duration(milliseconds: gapMs),
    );
  }

  final MatrixRecallPhase phase;
  final List<int> sequence;
  final int currentSequenceIndex;
  final int sequenceLength;
  final int gridSize;
  final int? litTileIndex;
  final int? wrongTileIndex;
  final int successToken;
  final int errorToken;
  final int roundToken;
  final bool isEvaluating;

  int get tileCount => gridSize * gridSize;

  bool get inputUnlocked =>
      phase == MatrixRecallPhase.play && !isEvaluating && wrongTileIndex == null;

  MatrixRecallState copyWith({
    MatrixRecallPhase? phase,
    List<int>? sequence,
    int? currentSequenceIndex,
    int? sequenceLength,
    int? gridSize,
    int? litTileIndex,
    int? wrongTileIndex,
    int? successToken,
    int? errorToken,
    int? roundToken,
    bool? isEvaluating,
    bool clearLitTile = false,
    bool clearWrongTile = false,
  }) {
    return MatrixRecallState(
      phase: phase ?? this.phase,
      sequence: sequence ?? this.sequence,
      currentSequenceIndex: currentSequenceIndex ?? this.currentSequenceIndex,
      sequenceLength: sequenceLength ?? this.sequenceLength,
      gridSize: gridSize ?? this.gridSize,
      litTileIndex: clearLitTile ? null : (litTileIndex ?? this.litTileIndex),
      wrongTileIndex:
          clearWrongTile ? null : (wrongTileIndex ?? this.wrongTileIndex),
      successToken: successToken ?? this.successToken,
      errorToken: errorToken ?? this.errorToken,
      roundToken: roundToken ?? this.roundToken,
      isEvaluating: isEvaluating ?? this.isEvaluating,
    );
  }
}

class MatrixRecallNotifier extends Notifier<MatrixRecallState> {
  int _generation = 0;

  @override
  MatrixRecallState build() {
    ref.onDispose(() {
      _generation++;
    });
    return MatrixRecallState.initial();
  }

  void reset() {
    _generation++;
    state = MatrixRecallState.initial();
    startRound(
      length: MatrixRecallState.initialSequenceLength,
      leadIn: MatrixRecallState.introDelay,
    );
  }

  void startRound({
    required int length,
    List<int>? excluding,
    Duration leadIn = MatrixRecallState.interRoundDelay,
  }) {
    final generation = ++_generation;
    final safeLength = length < 1 ? 1 : length;
    final sequence = MatrixRecallSequence.generate(
      length: safeLength,
      gridSize: state.gridSize,
      excluding: excluding,
    );

    state = state.copyWith(
      phase: MatrixRecallPhase.watch,
      sequence: sequence,
      currentSequenceIndex: 0,
      sequenceLength: safeLength,
      roundToken: state.roundToken + 1,
      isEvaluating: true,
      clearLitTile: true,
      clearWrongTile: true,
    );

    _beginWatchAfterLeadIn(generation, leadIn);
  }

  /// Discard the current sequence and generate a new one at the same length.
  void rerollCurrent() {
    final previous = state.sequence;
    startRound(
      length: state.sequenceLength,
      excluding: previous.isEmpty ? null : previous,
      leadIn: MatrixRecallState.interRoundDelay,
    );
  }

  Future<void> _beginWatchAfterLeadIn(
    int generation,
    Duration leadIn,
  ) async {
    if (leadIn > Duration.zero) {
      await _delay(leadIn, generation);
      if (!_isActive(generation)) {
        return;
      }
    }

    state = state.copyWith(isEvaluating: false);
    await _playWatchSequence(generation);
  }

  Future<void> _playWatchSequence(int generation) async {
    final sequence = state.sequence;
    final timings = MatrixRecallState.watchDurationsFor(sequence.length);
    for (var i = 0; i < sequence.length; i++) {
      if (!_isActive(generation)) {
        return;
      }

      await _waitWhilePaused(generation);
      if (!_isActive(generation)) {
        return;
      }

      state = state.copyWith(
        phase: MatrixRecallPhase.watch,
        currentSequenceIndex: i,
        litTileIndex: sequence[i],
        clearWrongTile: true,
      );

      await _delay(timings.lit, generation);
      if (!_isActive(generation)) {
        return;
      }

      state = state.copyWith(clearLitTile: true);

      if (i < sequence.length - 1) {
        await _delay(timings.gap, generation);
        if (!_isActive(generation)) {
          return;
        }
      }
    }

    if (!_isActive(generation)) {
      return;
    }

    state = state.copyWith(
      phase: MatrixRecallPhase.play,
      currentSequenceIndex: 0,
      clearLitTile: true,
      clearWrongTile: true,
      isEvaluating: false,
    );
  }

  void onTileTapped(int index) {
    if (!state.inputUnlocked) {
      return;
    }
    if (index < 0 || index >= state.tileCount) {
      return;
    }

    final expected = state.sequence[state.currentSequenceIndex];
    if (index == expected) {
      _onCorrectTap(index);
    } else {
      _onWrongTap(index);
    }
  }

  void _onCorrectTap(int index) {
    final nextIndex = state.currentSequenceIndex + 1;
    final completed = nextIndex >= state.sequence.length;

    state = state.copyWith(
      litTileIndex: index,
      currentSequenceIndex: nextIndex,
      successToken: completed ? state.successToken + 1 : state.successToken,
      isEvaluating: completed,
      clearWrongTile: true,
    );

    // Pay per correct tile slightly below Card Match match magnitude (+50).
    ref
        .read(gameSessionProvider.notifier)
        .addScore(MatrixRecallState.correctPoints);

    if (!completed) {
      final generation = _generation;
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (!_isActive(generation)) {
          return;
        }
        if (state.phase != MatrixRecallPhase.play) {
          return;
        }
        if (state.litTileIndex == index) {
          state = state.copyWith(clearLitTile: true);
        }
      });
      return;
    }

    final generation = _generation;
    Future<void>(() async {
      await _delay(MatrixRecallState.feedbackHoldDelay, generation);
      if (!_isActive(generation)) {
        return;
      }
      startRound(length: state.sequenceLength + 1);
    });
  }

  Future<void> _onWrongTap(int index) async {
    final generation = ++_generation;
    final previousSequence = List<int>.from(state.sequence);

    state = state.copyWith(
      wrongTileIndex: index,
      errorToken: state.errorToken + 1,
      isEvaluating: true,
      clearLitTile: true,
    );

    ref
        .read(gameSessionProvider.notifier)
        .addScore(MatrixRecallState.incorrectPenalty);

    await _delay(MatrixRecallState.feedbackHoldDelay, generation);
    if (!_isActive(generation)) {
      return;
    }

    startRound(
      length: state.sequenceLength,
      excluding: previousSequence,
    );
  }

  bool _isActive(int generation) => generation == _generation;

  Future<void> _delay(Duration duration, int generation) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      if (!_isActive(generation)) {
        return;
      }
      await _waitWhilePaused(generation);
      if (!_isActive(generation)) {
        return;
      }
      final remaining = end.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        return;
      }
      final slice = remaining < MatrixRecallState.pausePollInterval
          ? remaining
          : MatrixRecallState.pausePollInterval;
      await Future<void>.delayed(slice);
    }
  }

  Future<void> _waitWhilePaused(int generation) async {
    while (_isActive(generation) &&
        ref.read(gameSessionProvider).isPaused) {
      await Future<void>.delayed(MatrixRecallState.pausePollInterval);
    }
  }
}

final matrixRecallProvider =
    NotifierProvider<MatrixRecallNotifier, MatrixRecallState>(
  MatrixRecallNotifier.new,
);
