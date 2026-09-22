import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/game_session_notifier.dart';
import '../domain/asteroid.dart';

class VisualSortState {
  const VisualSortState({
    required this.currentLevel,
    required this.asteroids,
    required this.nextExpectedIndex,
    required this.isInputLocked,
    required this.shakingAsteroidId,
    required this.shakeToken,
    required this.boardGeneration,
  });

  factory VisualSortState.initial() {
    return const VisualSortState(
      currentLevel: 1,
      asteroids: [],
      nextExpectedIndex: 0,
      isInputLocked: false,
      shakingAsteroidId: null,
      shakeToken: 0,
      boardGeneration: 0,
    );
  }

  static const int completePoints = 100;
  static const int incorrectPenalty = -20;
  static const Duration popDelay = Duration(milliseconds: 280);
  static const Duration shakeDelay = Duration(milliseconds: 320);

  final int currentLevel;
  final List<Asteroid> asteroids;
  final int nextExpectedIndex;
  final bool isInputLocked;
  final int? shakingAsteroidId;
  final int shakeToken;
  final int boardGeneration;

  int? get nextExpectedId {
    if (asteroids.isEmpty ||
        nextExpectedIndex < 0 ||
        nextExpectedIndex >= asteroids.length) {
      return null;
    }
    final sorted = List<Asteroid>.from(asteroids)
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted[nextExpectedIndex].id;
  }

  VisualSortState copyWith({
    int? currentLevel,
    List<Asteroid>? asteroids,
    int? nextExpectedIndex,
    bool? isInputLocked,
    int? shakingAsteroidId,
    bool clearShakingAsteroidId = false,
    int? shakeToken,
    int? boardGeneration,
  }) {
    return VisualSortState(
      currentLevel: currentLevel ?? this.currentLevel,
      asteroids: asteroids ?? this.asteroids,
      nextExpectedIndex: nextExpectedIndex ?? this.nextExpectedIndex,
      isInputLocked: isInputLocked ?? this.isInputLocked,
      shakingAsteroidId: clearShakingAsteroidId
          ? null
          : (shakingAsteroidId ?? this.shakingAsteroidId),
      shakeToken: shakeToken ?? this.shakeToken,
      boardGeneration: boardGeneration ?? this.boardGeneration,
    );
  }
}

class VisualSortNotifier extends Notifier<VisualSortState> {
  Size _playfieldSize = Size.zero;
  int _evaluationGeneration = 0;

  @override
  VisualSortState build() => VisualSortState.initial();

  void reset() {
    _evaluationGeneration++;
    state = VisualSortState.initial();
  }

  void ensureSpawned(Size playfield) {
    if (playfield.shortestSide < 8) {
      return;
    }
    _playfieldSize = playfield;
    if (state.asteroids.isEmpty) {
      _spawnBoard(state.currentLevel);
    }
  }

  void onAsteroidTapped(int id) {
    if (state.isInputLocked) {
      return;
    }

    Asteroid? tapped;
    for (final asteroid in state.asteroids) {
      if (asteroid.id == id) {
        tapped = asteroid;
        break;
      }
    }
    if (tapped == null || tapped.isPopped) {
      return;
    }

    final expectedId = state.nextExpectedId;
    if (expectedId == null) {
      return;
    }

    if (tapped.id == expectedId) {
      _onCorrectTap(tapped);
      return;
    }

    _onWrongTap(tapped.id);
  }

  void _onCorrectTap(Asteroid tapped) {
    tapped.isPopped = true;
    final nextIndex = state.nextExpectedIndex + 1;
    final isLast = nextIndex >= state.asteroids.length;

    state = state.copyWith(
      asteroids: List<Asteroid>.from(state.asteroids),
      nextExpectedIndex: nextIndex,
      isInputLocked: isLast,
      clearShakingAsteroidId: true,
    );

    if (!isLast) {
      return;
    }

    ref
        .read(gameSessionProvider.notifier)
        .addScore(VisualSortState.completePoints);
    _advanceAfterPop();
  }

  Future<void> _advanceAfterPop() async {
    final generation = ++_evaluationGeneration;
    await Future<void>.delayed(VisualSortState.popDelay);
    if (generation != _evaluationGeneration) {
      return;
    }
    _spawnBoard(state.currentLevel + 1);
  }

  Future<void> _onWrongTap(int id) async {
    ref
        .read(gameSessionProvider.notifier)
        .addScore(VisualSortState.incorrectPenalty);

    state = state.copyWith(
      isInputLocked: true,
      shakingAsteroidId: id,
      shakeToken: state.shakeToken + 1,
    );

    final generation = ++_evaluationGeneration;
    await Future<void>.delayed(VisualSortState.shakeDelay);
    if (generation != _evaluationGeneration) {
      return;
    }
    _spawnBoard(state.currentLevel);
  }

  void _spawnBoard(int level) {
    if (_playfieldSize.shortestSide < 8) {
      state = VisualSortState(
        currentLevel: level < 1 ? 1 : level,
        asteroids: const [],
        nextExpectedIndex: 0,
        isInputLocked: false,
        shakingAsteroidId: null,
        shakeToken: 0,
        boardGeneration: state.boardGeneration + 1,
      );
      return;
    }

    final safeLevel = level < 1 ? 1 : level;
    state = VisualSortState(
      currentLevel: safeLevel,
      asteroids: AsteroidField.generate(safeLevel, _playfieldSize),
      nextExpectedIndex: 0,
      isInputLocked: false,
      shakingAsteroidId: null,
      shakeToken: 0,
      boardGeneration: state.boardGeneration + 1,
    );
  }

  /// Discard the current board and spawn a new one at the same level.
  void rerollCurrent() {
    _evaluationGeneration++;
    _spawnBoard(state.currentLevel);
  }
}

final visualSortProvider =
    NotifierProvider<VisualSortNotifier, VisualSortState>(
      VisualSortNotifier.new,
    );
