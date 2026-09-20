import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/color_clash_round.dart';

/// Massive Stroop target word that slides/fades in on every new round.
class StroopTargetWord extends StatelessWidget {
  const StroopTargetWord({super.key, required this.round});

  final ColorClashRound round;

  static const double fontSize = 68;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(round.identityKey),
      child: Text(
        round.targetWord,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: round.targetColor,
          height: 1.05,
          letterSpacing: 1.2,
          shadows: const [
            Shadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 220.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.28,
            end: 0,
            duration: 280.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
