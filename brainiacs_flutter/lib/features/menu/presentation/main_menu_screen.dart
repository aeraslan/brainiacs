import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import 'widgets/animated_background_elements.dart';
import 'widgets/candy_new_game_button.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
