import 'package:flutter/material.dart';

import 'orbital_rings_painter.dart';

enum GameBackgroundStyle {
  mathYellow,
  cubeOrange,
  memoryGreen,
}

class GameBackgroundTheme {
  const GameBackgroundTheme({
    required this.gradientColors,
    required this.ringColor,
    required this.scaffoldColor,
  });

  final List<Color> gradientColors;
  final Color ringColor;
  final Color scaffoldColor;
}

abstract final class GameBackgroundThemes {
  static const Color ringHighlight = Color(0x59FFFFFF);

  static GameBackgroundTheme forStyle(GameBackgroundStyle style) {
    return switch (style) {
      GameBackgroundStyle.mathYellow => const GameBackgroundTheme(
          gradientColors: [Color(0xFFFFF9E6), Color(0xFFFFE566)],
          ringColor: ringHighlight,
          scaffoldColor: Color(0xFFFFF9E6),
        ),
      GameBackgroundStyle.cubeOrange => const GameBackgroundTheme(
          gradientColors: [Color(0xFFFFF0E0), Color(0xFFFFBE7D)],
          ringColor: ringHighlight,
          scaffoldColor: Color(0xFFFFF0E0),
        ),
      GameBackgroundStyle.memoryGreen => const GameBackgroundTheme(
          gradientColors: [Color(0xFFEEFCE8), Color(0xFFA8E6A3)],
          ringColor: ringHighlight,
          scaffoldColor: Color(0xFFEEFCE8),
        ),
    };
  }
}

class GameScreenBackground extends StatelessWidget {
  const GameScreenBackground({
    super.key,
    required this.style,
    required this.child,
  });

  final GameBackgroundStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = GameBackgroundThemes.forStyle(style);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradientColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: OrbitalRingsPainter(ringColor: theme.ringColor),
          ),
          child,
        ],
      ),
    );
  }

  static Color scaffoldColorFor(GameBackgroundStyle style) {
    return GameBackgroundThemes.forStyle(style).scaffoldColor;
  }
}
