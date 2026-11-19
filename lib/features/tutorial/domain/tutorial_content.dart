import '../../../core/session/game_session_state.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Copy for the shared pre-game tutorial shell.
class TutorialContent {
  const TutorialContent({
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final List<String> steps;

  static TutorialContent forType(
    MiniGameType type,
    AppLocalizations l10n, {
    MathGameVariant mathVariant = MathGameVariant.quickMath,
    AnalyticGameVariant analyticVariant = AnalyticGameVariant.cubeCount,
    MemoryGameVariant memoryVariant = MemoryGameVariant.cardMatch,
    VisualGameVariant visualVariant = VisualGameVariant.visualSort,
  }) {
    return switch (type) {
      MiniGameType.math => switch (mathVariant) {
        MathGameVariant.quickMath => TutorialContent(
          title: l10n.tutorialQuickMathTitle,
          subtitle: l10n.tutorialQuickMathSubtitle,
          steps: [
            l10n.tutorialQuickMathStep1,
            l10n.tutorialQuickMathStep2,
            l10n.tutorialQuickMathStep3,
          ],
        ),
        MathGameVariant.missingOperator => TutorialContent(
          title: l10n.tutorialMissingOperatorTitle,
          subtitle: l10n.tutorialMissingOperatorSubtitle,
          steps: [
            l10n.tutorialMissingOperatorStep1,
            l10n.tutorialMissingOperatorStep2,
            l10n.tutorialMissingOperatorStep3,
          ],
        ),
      },
      MiniGameType.memory => switch (memoryVariant) {
        MemoryGameVariant.cardMatch => TutorialContent(
          title: l10n.tutorialCardMatchTitle,
          subtitle: l10n.tutorialCardMatchSubtitle,
          steps: [
            l10n.tutorialCardMatchStep1,
            l10n.tutorialCardMatchStep2,
            l10n.tutorialCardMatchStep3,
          ],
        ),
        MemoryGameVariant.matrixRecall => TutorialContent(
          title: l10n.tutorialMatrixRecallTitle,
          subtitle: l10n.tutorialMatrixRecallSubtitle,
          steps: [
            l10n.tutorialMatrixRecallStep1,
            l10n.tutorialMatrixRecallStep2,
            l10n.tutorialMatrixRecallStep3,
          ],
        ),
      },
      MiniGameType.analytical => switch (analyticVariant) {
        AnalyticGameVariant.cubeCount => TutorialContent(
          title: l10n.tutorialCubeCountTitle,
          subtitle: l10n.tutorialCubeCountSubtitle,
          steps: [
            l10n.tutorialCubeCountStep1,
            l10n.tutorialCubeCountStep2,
            l10n.tutorialCubeCountStep3,
          ],
        ),
        AnalyticGameVariant.balanceLogic => TutorialContent(
          title: l10n.tutorialBalanceLogicTitle,
          subtitle: l10n.tutorialBalanceLogicSubtitle,
          steps: [
            l10n.tutorialBalanceLogicStep1,
            l10n.tutorialBalanceLogicStep2,
            l10n.tutorialBalanceLogicStep3,
          ],
        ),
      },
      MiniGameType.visual => switch (visualVariant) {
        VisualGameVariant.visualSort => TutorialContent(
          title: l10n.tutorialAsteroidsTitle,
          subtitle: l10n.tutorialAsteroidsSubtitle,
          steps: [
            l10n.tutorialAsteroidsStep1,
            l10n.tutorialAsteroidsStep2,
            l10n.tutorialAsteroidsStep3,
          ],
        ),
        VisualGameVariant.colorClash => TutorialContent(
          title: l10n.tutorialColorClashTitle,
          subtitle: l10n.tutorialColorClashSubtitle,
          steps: [
            l10n.tutorialColorClashStep1,
            l10n.tutorialColorClashStep2,
            l10n.tutorialColorClashStep3,
          ],
        ),
      },
    };
  }
}
