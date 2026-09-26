import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/rank/title_progress_notifier.dart';
import '../../../core/rank/title_tier.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import '../../../shared/widgets/candy_button.dart';
import 'widgets/personal_best_badge.dart';
import 'widgets/end_match_celebration.dart';
import 'widgets/rank_defend_chip.dart';
import 'widgets/rank_reveal_dialog.dart';
import 'widgets/score_breakdown_panel.dart';
import 'widgets/score_count_up.dart';
import 'widgets/title_reveal_pill.dart';

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
    final titleProgress = ref.watch(titleProgressProvider);
    final sessionTitle =
        titleProgress.lastSessionTitle ?? TitleTier.fromScore(totalScore);
    final daysLeft = titleProgress.daysLeftToDefend(ref.read(clockProvider)());
    final headline = timeRemaining > 0 ? 'Game Over' : "Time's Up!";

    final RankDefendOutcome? defendOutcome;
    if (daysLeft == null ||
        (titleProgress.highestTitle == TitleTier.dormantMind &&
            !titleProgress.unlockedNewRank)) {
      defendOutcome = null;
    } else if (titleProgress.unlockedNewRank) {
      defendOutcome = RankDefendOutcome.unlocked;
    } else if (sessionTitle == titleProgress.highestTitle) {
      defendOutcome = RankDefendOutcome.defended;
    } else {
      defendOutcome = RankDefendOutcome.pending;
    }

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
                        newCategoryHighs: titleProgress.newCategoryHighs,
                        sessionTitle: sessionTitle,
                        heldTitle: titleProgress.highestTitle,
                        unlockedNewRank: titleProgress.unlockedNewRank,
                        daysLeftToDefend: daysLeft,
                        defendOutcome: defendOutcome,
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
    required this.newCategoryHighs,
    required this.sessionTitle,
    required this.heldTitle,
    required this.unlockedNewRank,
    required this.daysLeftToDefend,
    required this.defendOutcome,
    required this.onPlayAgain,
    required this.onMenu,
  });

  final String headline;
  final int totalScore;
  final Map<MiniGameType, int> scoresByGame;
  final Set<MiniGameType> newCategoryHighs;
  final TitleTier sessionTitle;
  final TitleTier heldTitle;
  final bool unlockedNewRank;
  final int? daysLeftToDefend;
  final RankDefendOutcome? defendOutcome;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final showThisRunCaption = defendOutcome == RankDefendOutcome.pending;

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
        if (unlockedNewRank) ...[
          const SizedBox(height: AppSpacing.md),
          const Center(child: PersonalBestBadge()),
        ],
        const SizedBox(height: AppSpacing.lg),
        ScoreCountUp(target: totalScore),
        const SizedBox(height: AppSpacing.md),
        if (showThisRunCaption) ...[
          Text(
            'This run',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        _RankRevealHost(earnedTitle: sessionTitle),
        if (defendOutcome != null && daysLeftToDefend != null) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: RankDefendChip(
              heldTitle: heldTitle,
              daysLeft: daysLeftToDefend!,
              outcome: defendOutcome!,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        ScoreBreakdownPanel(
          scoresByGame: scoresByGame,
          newCategoryHighs: newCategoryHighs,
        ),
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

/// Opens [RankRevealDialog] once after the score count-up, then shows a
/// static [TitleRevealPill] so the hub still displays the earned rank.
class _RankRevealHost extends StatefulWidget {
  const _RankRevealHost({required this.earnedTitle});

  final TitleTier earnedTitle;

  @override
  State<_RankRevealHost> createState() => _RankRevealHostState();
}

class _RankRevealHostState extends State<_RankRevealHost> {
  /// Approximate height of [TitleRevealPill] to avoid layout jump.
  static const double _pillPlaceholderHeight = 56;

  /// Extra beat after the score finishes counting so the total can land
  /// before the rank spin steals focus.
  static const Duration _postScorePause = Duration(milliseconds: 900);

  bool _dialogShown = false;
  bool _revealComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleReveal());
  }

  Future<void> _scheduleReveal() async {
    if (_dialogShown || !mounted) {
      return;
    }
    await Future<void>.delayed(ScoreCountUp.countDuration + _postScorePause);
    if (!mounted || _dialogShown) {
      return;
    }
    _dialogShown = true;
    await RankRevealDialog.show(context, earnedTitle: widget.earnedTitle);
    if (!mounted) {
      return;
    }
    setState(() => _revealComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_revealComplete) {
      return Center(
        child: TitleRevealPill(
          tier: widget.earnedTitle,
          revealDelay: Duration.zero,
        ),
      );
    }
    return const SizedBox(height: _pillPlaceholderHeight);
  }
}
