import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/game_session_notifier.dart';
import '../../core/session/game_session_state.dart';
import 'pause_menu_dialog.dart';

/// Owns the single Pause menu for active gameplay.
///
/// Listens for [GameSessionState.pauseMenuRequestId] bumps (manual HUD/Back or
/// automatic lifecycle) and opens [PauseMenuDialog] at most once at a time.
class GameplayPauseHost extends ConsumerStatefulWidget {
  const GameplayPauseHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GameplayPauseHost> createState() => _GameplayPauseHostState();
}

class _GameplayPauseHostState extends ConsumerState<GameplayPauseHost> {
  bool _dialogOpen = false;
  int _handledRequestId = 0;

  Future<void> _openPauseMenuIfNeeded(int requestId) async {
    if (_dialogOpen || requestId <= _handledRequestId) {
      return;
    }
    _handledRequestId = requestId;

    final session = ref.read(gameSessionProvider);
    if (session.phase != GamePhase.playing || !session.isPaused) {
      return;
    }

    _dialogOpen = true;
    final action = await PauseMenuDialog.show(
      context,
      isPracticeMode: session.isPracticeMode,
      pauseOrigin: session.pauseOrigin,
      manualPauseNumber: session.pauseCount,
      pendingPenaltySeconds: session.pendingResumePenaltySeconds,
    );

    if (!mounted) {
      return;
    }
    _dialogOpen = false;

    final notifier = ref.read(gameSessionProvider.notifier);
    switch (action) {
      case PauseMenuAction.resume:
        notifier.resumeGame();
      case PauseMenuAction.endPractice:
        notifier.endSessionEarly();
      case PauseMenuAction.quitToMenu:
        notifier.resetToMenu();
      case null:
        // Dialog should not dismiss without an action; resume as a safety net.
        if (ref.read(gameSessionProvider).isPaused) {
          notifier.resumeGame();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      gameSessionProvider.select((s) => s.pauseMenuRequestId),
      (previous, next) {
        if (next > (previous ?? 0)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _openPauseMenuIfNeeded(next);
          });
        }
      },
    );

    return widget.child;
  }
}
