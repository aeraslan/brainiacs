import '../../../core/session/game_session_state.dart';

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
    MiniGameType type, {
    MathGameVariant mathVariant = MathGameVariant.quickMath,
    AnalyticGameVariant analyticVariant = AnalyticGameVariant.cubeCount,
    MemoryGameVariant memoryVariant = MemoryGameVariant.cardMatch,
    VisualGameVariant visualVariant = VisualGameVariant.visualSort,
  }) {
    return switch (type) {
      MiniGameType.math => switch (mathVariant) {
        MathGameVariant.quickMath => const TutorialContent(
          title: 'Quick Math',
          subtitle: 'Solve the equation as fast as you can.',
          steps: [
            'Solve the equation.',
            'Tap the digits of the answer.',
            'Correct answers unlock harder sums.',
          ],
        ),
        MathGameVariant.missingOperator => const TutorialContent(
          title: 'Missing Operator',
          subtitle: 'Complete the equation with the right operator.',
          steps: [
            'Find the missing operator to complete the equation.',
            'Answer correctly to unlock harder equations.',
            'Think fast, but stay accurate!',
          ],
        ),
      },
      MiniGameType.memory => switch (memoryVariant) {
        MemoryGameVariant.cardMatch => const TutorialContent(
          title: 'Card Match',
          subtitle: 'Memorize, then match the pairs.',
          steps: [
            'Memorize the cards while they are face up.',
            'Flip two cards to find a pair.',
            'Clear the board to get more cards.',
          ],
        ),
        MemoryGameVariant.matrixRecall => const TutorialContent(
          title: 'Matrix Recall',
          subtitle: 'Watch the sequence, then tap it back.',
          steps: [
            'Watch the tiles light up.',
            'Tap them back in the same order.',
            'Each round adds one more tile.',
          ],
        ),
      },
      MiniGameType.analytical => switch (analyticVariant) {
        AnalyticGameVariant.cubeCount => const TutorialContent(
          title: 'Cube Count',
          subtitle: 'Count every cube in the stack.',
          steps: [
            'Count every cube, including hidden ones.',
            'Enter the total on the pad.',
            'Correct counts unlock taller stacks.',
          ],
        ),
        AnalyticGameVariant.balanceLogic => const TutorialContent(
          title: 'Balance Logic',
          subtitle: 'Use the scales to compare weights.',
          steps: [
            'Read the scales.',
            'Pick the heaviest object.',
            'Correct picks unlock tougher puzzles.',
          ],
        ),
      },
      MiniGameType.visual => switch (visualVariant) {
        VisualGameVariant.visualSort => const TutorialContent(
          title: 'Asteroids',
          subtitle: 'Tap the asteroids in ascending order.',
          steps: [
            'Tap the asteroids from lowest to highest.',
            'A wrong tap shakes the asteroid.',
            'Clear the field to face more asteroids.',
          ],
        ),
        VisualGameVariant.colorClash => const TutorialContent(
          title: 'Color Clash',
          subtitle: 'Follow the rule: match the ink or the word.',
          steps: [
            'Check the rule: ink color or word.',
            'Tap the matching color.',
            'Correct answers unlock tougher clashes.',
          ],
        ),
      },
    };
  }
}
