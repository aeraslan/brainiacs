import 'package:flutter/material.dart';

import '../../core/session/game_session_state.dart';

/// Shared candy styling for the four mini-game categories.
extension MiniGameCategoryStyle on MiniGameType {
  String get label => switch (this) {
        MiniGameType.math => 'Math',
        MiniGameType.memory => 'Memory',
        MiniGameType.analytical => 'Analytic',
        MiniGameType.visual => 'Visual',
      };

  IconData get icon => switch (this) {
        MiniGameType.math => Icons.calculate_rounded,
        MiniGameType.memory => Icons.psychology_rounded,
        MiniGameType.analytical => Icons.extension_rounded,
        MiniGameType.visual => Icons.visibility_rounded,
      };

  /// Soft candy accent matching each game background family.
  Color get color => switch (this) {
        // Matches GameBackgroundStyle.mathYellow accent.
        MiniGameType.math => const Color(0xFFFFE566),
        // Matches GameBackgroundStyle.memoryGreen accent.
        MiniGameType.memory => const Color(0xFFA8E6A3),
        // Matches GameBackgroundStyle.cubeOrange accent.
        MiniGameType.analytical => const Color(0xFFFFBE7D),
        // Matches VisualColors.sky.
        MiniGameType.visual => const Color(0xFF7EC8E3),
      };
}
