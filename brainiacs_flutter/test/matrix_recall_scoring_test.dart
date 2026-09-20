import 'package:brainiacs_flutter/core/session/game_session_notifier.dart';
import 'package:brainiacs_flutter/core/session/game_session_state.dart';
import 'package:brainiacs_flutter/features/memory/presentation/matrix_recall_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> waitUntilPlay(ProviderContainer container) async {
    // Length-3 watch: 3×600ms lit + 2×200ms gap ≈ 2200ms.
    for (var i = 0; i < 50; i++) {
      if (container.read(matrixRecallProvider).phase == MatrixRecallPhase.play) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  test('each correct Matrix Recall tile awards 100 points', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.memory,
      memoryVariant: MemoryGameVariant.matrixRecall,
    );
    session.beginPlaying();

    final recall = container.read(matrixRecallProvider.notifier);
    recall.startRound(length: 3, leadIn: Duration.zero);
    await waitUntilPlay(container);

    final state = container.read(matrixRecallProvider);
    expect(state.phase, MatrixRecallPhase.play);
    expect(state.sequence, hasLength(3));

    for (final tile in state.sequence) {
      recall.onTileTapped(tile);
    }

    expect(container.read(gameSessionProvider).totalScore, 300);
    expect(
      container.read(gameSessionProvider).scoreFor(MiniGameType.memory),
      300,
    );
  });

  test('wrong Matrix Recall tap awards -20 and no credit for missed tile',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(gameSessionProvider.notifier);
    session.startPractice(
      type: MiniGameType.memory,
      memoryVariant: MemoryGameVariant.matrixRecall,
    );
    session.beginPlaying();

    final recall = container.read(matrixRecallProvider.notifier);
    recall.startRound(length: 3, leadIn: Duration.zero);
    await waitUntilPlay(container);

    final state = container.read(matrixRecallProvider);
    expect(state.phase, MatrixRecallPhase.play);

    recall.onTileTapped(state.sequence[0]);
    expect(container.read(gameSessionProvider).totalScore, 100);

    var miss = (state.sequence[1] + 1) % state.tileCount;
    if (miss == state.sequence[1]) {
      miss = (miss + 1) % state.tileCount;
    }
    recall.onTileTapped(miss);

    expect(container.read(gameSessionProvider).totalScore, 80);
  });
}
