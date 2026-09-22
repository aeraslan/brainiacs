import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytical/presentation/balance_logic_notifier.dart';
import '../../features/analytical/presentation/cube_count_notifier.dart';
import '../../features/math/presentation/missing_operator_notifier.dart';
import '../../features/math/presentation/quick_math_notifier.dart';
import '../../features/memory/presentation/card_match_notifier.dart';
import '../../features/memory/presentation/matrix_recall_notifier.dart';
import '../../features/visual/presentation/color_clash_notifier.dart';
import '../../features/visual/presentation/visual_sort_notifier.dart';
import 'game_session_notifier.dart';
import 'game_session_state.dart';

/// Re-rolls the puzzle for whichever mini-game is currently active.
///
/// Called after Home → Resume so the player cannot memorize the obscured
/// question. Difficulty / level / sequence length are preserved.
void rerollActivePuzzle(WidgetRef ref) {
  final session = ref.read(gameSessionProvider);

  switch (session.currentGame) {
    case MiniGameType.math:
      switch (session.mathVariant) {
        case MathGameVariant.quickMath:
          ref.read(quickMathProvider.notifier).rerollCurrent();
        case MathGameVariant.missingOperator:
          ref.read(missingOperatorProvider.notifier).rerollCurrent();
      }
    case MiniGameType.memory:
      switch (session.memoryVariant) {
        case MemoryGameVariant.cardMatch:
          ref.read(cardMatchProvider.notifier).rerollCurrent();
        case MemoryGameVariant.matrixRecall:
          ref.read(matrixRecallProvider.notifier).rerollCurrent();
      }
    case MiniGameType.analytical:
      switch (session.analyticVariant) {
        case AnalyticGameVariant.cubeCount:
          ref.read(cubeCountProvider.notifier).rerollCurrent();
        case AnalyticGameVariant.balanceLogic:
          ref.read(balanceLogicProvider.notifier).rerollCurrent();
      }
    case MiniGameType.visual:
      switch (session.visualVariant) {
        case VisualGameVariant.visualSort:
          ref.read(visualSortProvider.notifier).rerollCurrent();
        case VisualGameVariant.colorClash:
          ref.read(colorClashProvider.notifier).rerollCurrent();
      }
  }
}
