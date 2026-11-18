import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/widgets/scroll_more_cue.dart';
import 'widgets/category_records_section.dart';
import 'widgets/performance_chart.dart';
import 'widgets/primary_stats_grid.dart';
import 'widgets/progress_rank_card.dart';

class MyProgressScreen extends ConsumerWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        ref.read(gameSessionProvider.notifier).closeMyProgress();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () {
                        ref
                            .read(gameSessionProvider.notifier)
                            .closeMyProgress();
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        'My Progress',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ScrollOverflowHint(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AnimatedSection(
                        reduceMotion: reduceMotion,
                        delay: Duration.zero,
                        child: const ProgressRankCard(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _AnimatedSection(
                        reduceMotion: reduceMotion,
                        delay: 80.ms,
                        child: const PrimaryStatsGrid(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _AnimatedSection(
                        reduceMotion: reduceMotion,
                        delay: 160.ms,
                        child: const CategoryRecordsSection(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _AnimatedSection(
                        reduceMotion: reduceMotion,
                        delay: 240.ms,
                        child: const PerformanceChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.child,
    required this.delay,
    required this.reduceMotion,
  });

  final Widget child;
  final Duration delay;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) {
      return child;
    }
    return child
        .animate()
        .fadeIn(delay: delay, duration: 280.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          delay: delay,
          duration: 340.ms,
          curve: Curves.easeOut,
        );
  }
}
