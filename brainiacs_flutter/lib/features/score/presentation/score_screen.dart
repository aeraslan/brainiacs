import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import '../../../shared/widgets/candy_button.dart';
import 'widgets/daily_streak_chip.dart';
import 'widgets/end_match_celebration.dart';
import 'widgets/personal_best_badge.dart';
import 'widgets/score_breakdown_panel.dart';
import 'widgets/score_count_up.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalScore = ref.watch(
      gameSessionProvider.select((s) => s.totalScore),
    );
    final timeRemaining = ref.watch(
      gameSessionProvider.select((s) => s.timeRemaining),
    );
    final scoresByGame = ref.watch(
      gameSessionProvider.select((s) => s.scoresByGame),
    );
    final headline = timeRemaining > 0 ? 'Game Over' : "Time's Up!";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const EndMatchCelebration(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSpacing.lg * 2,
                    ),
                    child: IntrinsicHeight(
                      child: _ScoreHubContent(
                        headline: headline,
                        totalScore: totalScore,
                        scoresByGame: scoresByGame,
                        onPlayAgain: () {
                          ref.read(gameSessionProvider.notifier).startGame();
                        },
                        onMenu: () {
                          ref.read(gameSessionProvider.notifier).resetToMenu();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHubContent extends StatelessWidget {
  const _ScoreHubContent({
    required this.headline,
    required this.totalScore,
    required this.scoresByGame,
    required this.onPlayAgain,
    required this.onMenu,
  });

  final String headline;
  final int totalScore;
  final Map<MiniGameType, int> scoresByGame;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
              headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            )
            .animate()
            .fadeIn(duration: 180.ms)
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              duration: 320.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: AppSpacing.md),
        const Center(child: PersonalBestBadge()),
        const SizedBox(height: AppSpacing.lg),
        ScoreCountUp(target: totalScore),
        const SizedBox(height: AppSpacing.md),
        const Center(child: DailyStreakChip()),
        const SizedBox(height: AppSpacing.lg),
        ScoreBreakdownPanel(scoresByGame: scoresByGame),
        const SizedBox(height: AppSpacing.xl),
        CandyButton(label: 'Play Again', onPressed: onPlayAgain),
        const SizedBox(height: AppSpacing.md),
        CandyButton(
          label: 'Menu',
          variant: CandyButtonVariant.secondary,
          onPressed: onMenu,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
