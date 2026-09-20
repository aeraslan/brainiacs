import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/tutorial/tutorial_pointer.dart';
import '../../../shared/widgets/game_hud.dart';
import 'visual_colors.dart';
import 'visual_sort_notifier.dart';
import 'widgets/asteroid_playfield.dart';

class VisualSortScreen extends ConsumerStatefulWidget {
  const VisualSortScreen({
    super.key,
    this.isTutorial = false,
    this.autoPlay = true,
    this.pointerController,
  });

  final bool isTutorial;
  final bool autoPlay;
  final TutorialPointerController? pointerController;

  @override
  ConsumerState<VisualSortScreen> createState() => _VisualSortScreenState();
}

class _VisualSortScreenState extends ConsumerState<VisualSortScreen> {
  final Map<int, GlobalKey> _asteroidKeys = {};
  int _tutorialToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(visualSortProvider.notifier).reset();
      if (widget.isTutorial && widget.autoPlay) {
        _runTutorial();
      }
    });
  }

  @override
  void didUpdateWidget(VisualSortScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay && !widget.autoPlay) {
      _tutorialToken++;
      widget.pointerController?.hide();
    }
  }

  @override
  void dispose() {
    _tutorialToken++;
    super.dispose();
  }

  void _syncAsteroidKeys() {
    final asteroids = ref.read(visualSortProvider).asteroids;
    final ids = {for (final asteroid in asteroids) asteroid.id};
    _asteroidKeys.removeWhere((id, _) => !ids.contains(id));
    for (final asteroid in asteroids) {
      _asteroidKeys.putIfAbsent(asteroid.id, GlobalKey.new);
    }
  }

  bool _isTutorialActive(int token) {
    return mounted &&
        token == _tutorialToken &&
        widget.isTutorial &&
        widget.autoPlay;
  }

  Future<void> _runTutorial() async {
    final token = ++_tutorialToken;
    final pointer = widget.pointerController;
    if (pointer == null) {
      return;
    }

    while (_isTutorialActive(token)) {
      await _waitForPlayableBoard(token);
      if (!_isTutorialActive(token)) {
        return;
      }

      await _tapNextExpected(token);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!_isTutorialActive(token)) {
        return;
      }

      final wrongId = _wrongAsteroidId();
      if (wrongId != null) {
        await _tapAsteroid(wrongId, token, mustBeExpected: false);
        await Future<void>.delayed(VisualSortState.shakeDelay);
        await Future<void>.delayed(const Duration(milliseconds: 550));
      }

      await _waitForPlayableBoard(token);
      if (!_isTutorialActive(token)) {
        return;
      }
      await _playCorrectSequence(token);
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
  }

  Future<void> _waitForPlayableBoard(int token) {
    return waitUntil(
      () =>
          ref.read(visualSortProvider).asteroids.isNotEmpty &&
          !ref.read(visualSortProvider).isInputLocked,
      isActive: () => _isTutorialActive(token),
    );
  }

  Future<void> _playCorrectSequence(int token) async {
    final remaining = ref
        .read(visualSortProvider)
        .asteroids
        .where((asteroid) => !asteroid.isPopped)
        .length;
    for (var i = 0; i < remaining; i++) {
      if (!_isTutorialActive(token)) {
        return;
      }
      await _tapNextExpected(token);
      await Future<void>.delayed(const Duration(milliseconds: 450));
    }
  }

  Future<void> _tapNextExpected(int token) async {
    await waitUntil(
      () =>
          !ref.read(visualSortProvider).isInputLocked &&
          ref.read(visualSortProvider).nextExpectedId != null,
      isActive: () => _isTutorialActive(token),
    );
    final expectedId = ref.read(visualSortProvider).nextExpectedId;
    if (expectedId == null) {
      return;
    }
    await _tapAsteroid(expectedId, token);
  }

  int? _wrongAsteroidId() {
    final state = ref.read(visualSortProvider);
    final expectedId = state.nextExpectedId;
    for (final asteroid in state.asteroids) {
      if (!asteroid.isPopped && asteroid.id != expectedId) {
        return asteroid.id;
      }
    }
    return null;
  }

  Future<void> _tapAsteroid(
    int id,
    int token, {
    bool mustBeExpected = true,
  }) async {
    final pointer = widget.pointerController;
    if (pointer == null || !_isTutorialActive(token)) {
      return;
    }

    _syncAsteroidKeys();
    final key = _asteroidKeys[id];
    if (key == null) {
      return;
    }

    await waitUntil(
      () => key.currentContext != null,
      isActive: () => _isTutorialActive(token),
    );
    if (!_isTutorialActive(token)) {
      return;
    }

    final didTap = await pointer.tapKey(key);
    if (!_isTutorialActive(token) || !didTap) {
      return;
    }
    if (mustBeExpected && ref.read(visualSortProvider).nextExpectedId != id) {
      return;
    }
    ref.read(visualSortProvider.notifier).onAsteroidTapped(id);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(visualSortProvider.select((s) => s.boardGeneration));
    _syncAsteroidKeys();

    return Scaffold(
      backgroundColor: VisualColors.sky,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              if (!widget.isTutorial) ...[
                const GameHud(isOnLightBackground: true),
                const SizedBox(height: AppSpacing.sm),
              ],
              Expanded(
                child: AsteroidPlayfield(
                  asteroidKeys: widget.isTutorial ? _asteroidKeys : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
