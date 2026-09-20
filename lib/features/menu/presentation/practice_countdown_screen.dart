import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../core/session/game_session_state.dart';
import '../../../shared/widgets/countdown_overlay.dart';
import '../../visual/presentation/visual_colors.dart';

/// 3-2-1-GO countdown shown before a practice run starts.
class PracticeCountdownScreen extends ConsumerWidget {
  const PracticeCountdownScreen({super.key});

  Color _accentFor(MiniGameType type) {
    return switch (type) {
      MiniGameType.math => const Color(0xFFFFE566),
      MiniGameType.memory => const Color(0xFFA8E6A3),
      MiniGameType.analytical => const Color(0xFFFFBE7D),
      MiniGameType.visual => VisualColors.sky,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGame = ref.watch(
      gameSessionProvider.select((state) => state.currentGame),
    );

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: CountdownOverlay(
        onComplete: () {
          ref.read(gameSessionProvider.notifier).beginPlaying();
        },
        accentColor: _accentFor(currentGame),
      ),
    );
  }
}
