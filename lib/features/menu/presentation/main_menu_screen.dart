import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/rank/title_progress_notifier.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/widgets/candy_button.dart';
import 'widgets/animated_background_elements.dart';
import 'widgets/candy_new_game_button.dart';
import 'widgets/current_rank_pill.dart';
import 'widgets/rank_decay_dialog.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  bool _decayDialogQueued = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final highestTitle = ref.watch(
      titleProgressProvider.select((s) => s.highestTitle),
    );

    ref.listen(titleProgressProvider, (previous, next) {
      if (!next.isHydrated || !next.hasDecayed || _decayDialogQueued) {
        return;
      }
      _decayDialogQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        await RankDecayDialog.show(context);
        if (!mounted) {
          return;
        }
        ref.read(titleProgressProvider.notifier).acknowledgeDecay();
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedBackgroundElements(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Leaderboard',
                        onPressed: () {},
                        icon: const Icon(Icons.leaderboard_outlined),
                        color: AppColors.textPrimary,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Profile/Stats'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Brainiacs',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.accent,
                      shadows: const [
                        Shadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Train your brain. Beat the clock.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(child: CurrentRankPill(tier: highestTitle)),
                  const Spacer(),
                  CandyNewGameButton(
                        onPressed: () {
                          ref.read(gameSessionProvider.notifier).startGame();
                        },
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 700.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: AppSpacing.md),
                  CandyButton(
                    label: 'Practice',
                    variant: CandyButtonVariant.secondary,
                    onPressed: () {
                      ref.read(gameSessionProvider.notifier).openPracticeMenu();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
