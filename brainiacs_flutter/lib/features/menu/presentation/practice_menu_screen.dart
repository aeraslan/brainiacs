import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import 'widgets/practice_game_tile.dart';

class PracticeMenuScreen extends ConsumerWidget {
  const PracticeMenuScreen({super.key});

  static const List<_PracticeGameCatalogItem> _catalog = [
    _PracticeGameCatalogItem(
      label: 'Quick Ops',
      icon: Icons.calculate_rounded,
      type: MiniGameType.math,
      mathVariant: MathGameVariant.quickMath,
      gradientColors: [
        Color(0xFFFF8E8E),
        AppColors.coral,
        Color(0xFFE84E4E),
      ],
      softShadowColor: Color(0x33FF6B6B),
    ),
    _PracticeGameCatalogItem(
      label: 'Missing Op',
      icon: Icons.functions_rounded,
      type: MiniGameType.math,
      mathVariant: MathGameVariant.missingOperator,
      gradientColors: [
        Color(0xFFFFD54F),
        AppColors.sunnyYellow,
        Color(0xFFFFA726),
      ],
      softShadowColor: Color(0x33FFE66D),
    ),
    _PracticeGameCatalogItem(
      label: 'Cards',
      icon: Icons.style_rounded,
      type: MiniGameType.memory,
      memoryVariant: MemoryGameVariant.cardMatch,
      gradientColors: [
        Color(0xFF7DD3E8),
        AppColors.electricBlue,
        Color(0xFF2A9BB8),
      ],
      softShadowColor: Color(0x3345B7D1),
    ),
    _PracticeGameCatalogItem(
      label: 'Recall',
      icon: Icons.grid_view_rounded,
      type: MiniGameType.memory,
      memoryVariant: MemoryGameVariant.matrixRecall,
      gradientColors: [
        Color(0xFFA8E6A3),
        AppColors.mint,
        Color(0xFF2BA89F),
      ],
      softShadowColor: Color(0x334ECDC4),
    ),
    _PracticeGameCatalogItem(
      label: 'Cube Count',
      icon: Icons.view_in_ar_rounded,
      type: MiniGameType.analytical,
      analyticVariant: AnalyticGameVariant.cubeCount,
      gradientColors: [
        Color(0xFFB57AEE),
        AppColors.vibrantPurple,
        Color(0xFF7A45C4),
      ],
      softShadowColor: Color(0x339B5DE5),
    ),
    _PracticeGameCatalogItem(
      label: 'Balance',
      icon: Icons.balance_rounded,
      type: MiniGameType.analytical,
      analyticVariant: AnalyticGameVariant.balanceLogic,
      gradientColors: [
        Color(0xFFFFBE7D),
        AppColors.coral,
        Color(0xFFE84E4E),
      ],
      softShadowColor: Color(0x33FF6B6B),
    ),
    _PracticeGameCatalogItem(
      label: 'Asteroids',
      icon: Icons.rocket_launch_rounded,
      type: MiniGameType.visual,
      visualVariant: VisualGameVariant.visualSort,
      gradientColors: [
        Color(0xFF7EE8E0),
        AppColors.mint,
        Color(0xFF2BA89F),
      ],
      softShadowColor: Color(0x334ECDC4),
    ),
    _PracticeGameCatalogItem(
      label: 'Color Clash',
      icon: Icons.palette_rounded,
      type: MiniGameType.visual,
      visualVariant: VisualGameVariant.colorClash,
      gradientColors: [
        Color(0xFF9AD8F0),
        Color(0xFF7EC8E3),
        Color(0xFF4ECDC4),
      ],
      softShadowColor: Color(0x337EC8E3),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
                      ref.read(gameSessionProvider.notifier).resetToMenu();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Text(
                      'Practice',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(AppSpacing.lg),
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1,
                children: [
                  for (var i = 0; i < _catalog.length; i++)
                    PracticeGameTile(
                          label: _catalog[i].label,
                          icon: _catalog[i].icon,
                          gradientColors: _catalog[i].gradientColors,
                          softShadowColor: _catalog[i].softShadowColor,
                          onPressed: () {
                            ref
                                .read(gameSessionProvider.notifier)
                                .startPractice(
                                  type: _catalog[i].type,
                                  mathVariant: _catalog[i].mathVariant,
                                  analyticVariant: _catalog[i].analyticVariant,
                                  memoryVariant: _catalog[i].memoryVariant,
                                  visualVariant: _catalog[i].visualVariant,
                                );
                          },
                        )
                        .animate()
                        .fadeIn(
                          delay: (i * 80).ms,
                          duration: 280.ms,
                        )
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          delay: (i * 80).ms,
                          duration: 360.ms,
                          curve: Curves.easeOutBack,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeGameCatalogItem {
  const _PracticeGameCatalogItem({
    required this.label,
    required this.icon,
    required this.type,
    required this.gradientColors,
    required this.softShadowColor,
    this.mathVariant = MathGameVariant.quickMath,
    this.analyticVariant = AnalyticGameVariant.cubeCount,
    this.memoryVariant = MemoryGameVariant.cardMatch,
    this.visualVariant = VisualGameVariant.visualSort,
  });

  final String label;
  final IconData icon;
  final MiniGameType type;
  final MathGameVariant mathVariant;
  final AnalyticGameVariant analyticVariant;
  final MemoryGameVariant memoryVariant;
  final VisualGameVariant visualVariant;
  final List<Color> gradientColors;
  final Color softShadowColor;
}
