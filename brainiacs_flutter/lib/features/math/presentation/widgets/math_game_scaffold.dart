import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/game_hud.dart';
import '../../../../shared/widgets/game_screen_background.dart';

/// Shared Math-family layout: yellow backdrop, HUD, board, and controls.
class MathGameScaffold extends StatelessWidget {
  const MathGameScaffold({
    super.key,
    required this.board,
    required this.controls,
    this.isTutorial = false,
  });

  final Widget board;
  final Widget controls;
  final bool isTutorial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameScreenBackground.scaffoldColorFor(
        GameBackgroundStyle.mathYellow,
      ),
      body: GameScreenBackground(
        style: GameBackgroundStyle.mathYellow,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (!isTutorial) const GameHud(isOnLightBackground: true),
                const Spacer(),
                board,
                const Spacer(),
                Expanded(flex: 5, child: controls),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
