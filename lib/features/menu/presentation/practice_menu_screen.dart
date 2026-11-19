import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/practice_game_tile.dart';

class PracticeMenuScreen extends ConsumerWidget {
  const PracticeMenuScreen({super.key});

  static List<_PracticeGameCatalogItem> _catalog(AppLocalizations l10n) {
    return [
      _PracticeGameCatalogItem(
        label: l10n.practiceQuickOps,
        icon: Icons.calculate_rounded,
        type: MiniGameType.math,
        mathVariant: MathGameVariant.quickMath,
        gradientColors: const [
          Color(0xFFFF8E8E),
          AppColors.coral,
          Color(0xFFE84E4E),
        ],
        softShadowColor: const Color(0x33FF6B6B),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceMissingOp,
        icon: Icons.functions_rounded,
        type: MiniGameType.math,
        mathVariant: MathGameVariant.missingOperator,
        gradientColors: const [
          Color(0xFFFFD54F),
          AppColors.sunnyYellow,
          Color(0xFFFFA726),
        ],
        softShadowColor: const Color(0x33FFE66D),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceCards,
        icon: Icons.style_rounded,
        type: MiniGameType.memory,
        memoryVariant: MemoryGameVariant.cardMatch,
        gradientColors: const [
          Color(0xFF7DD3E8),
          AppColors.electricBlue,
          Color(0xFF2A9BB8),
        ],
        softShadowColor: const Color(0x3345B7D1),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceRecall,
        icon: Icons.grid_view_rounded,
        type: MiniGameType.memory,
        memoryVariant: MemoryGameVariant.matrixRecall,
        gradientColors: const [
          Color(0xFFA8E6A3),
          AppColors.mint,
          Color(0xFF2BA89F),
        ],
        softShadowColor: const Color(0x334ECDC4),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceCubeCount,
        icon: Icons.view_in_ar_rounded,
        type: MiniGameType.analytical,
        analyticVariant: AnalyticGameVariant.cubeCount,
        gradientColors: const [
          Color(0xFFB57AEE),
          AppColors.vibrantPurple,
          Color(0xFF7A45C4),
        ],
        softShadowColor: const Color(0x339B5DE5),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceBalance,
        icon: Icons.balance_rounded,
        type: MiniGameType.analytical,
        analyticVariant: AnalyticGameVariant.balanceLogic,
        gradientColors: const [
          Color(0xFFFFBE7D),
          AppColors.coral,
          Color(0xFFE84E4E),
        ],
        softShadowColor: const Color(0x33FF6B6B),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceAsteroids,
        icon: Icons.rocket_launch_rounded,
        type: MiniGameType.visual,
        visualVariant: VisualGameVariant.visualSort,
        gradientColors: const [
          Color(0xFF7EE8E0),
          AppColors.mint,
          Color(0xFF2BA89F),
        ],
        softShadowColor: const Color(0x334ECDC4),
      ),
      _PracticeGameCatalogItem(
        label: l10n.practiceColorClash,
        icon: Icons.palette_rounded,
        type: MiniGameType.visual,
        visualVariant: VisualGameVariant.colorClash,
        gradientColors: const [
          Color(0xFF9AD8F0),
          Color(0xFF7EC8E3),
          Color(0xFF4ECDC4),
        ],
        softShadowColor: const Color(0x337EC8E3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final catalog = _catalog(l10n);

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
                    tooltip: l10n.commonBack,
                    onPressed: () {
                      ref.read(gameSessionProvider.notifier).resetToMenu();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Text(
                      l10n.practiceTitle,
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
                  for (var i = 0; i < catalog.length; i++)
                    PracticeGameTile(
                          label: catalog[i].label,
                          icon: catalog[i].icon,
                          gradientColors: catalog[i].gradientColors,
                          softShadowColor: catalog[i].softShadowColor,
                          onPressed: () {
                            ref
                                .read(gameSessionProvider.notifier)
                                .startPractice(
                                  type: catalog[i].type,
                                  mathVariant: catalog[i].mathVariant,
                                  analyticVariant: catalog[i].analyticVariant,
                                  memoryVariant: catalog[i].memoryVariant,
                                  visualVariant: catalog[i].visualVariant,
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
