import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../domain/color_clash_round.dart';
import '../stroop_color_names.dart';

/// Massive Stroop target word that slides/fades in on every new round.
class StroopTargetWord extends StatelessWidget {
  const StroopTargetWord({super.key, required this.round});

  final ColorClashRound round;

  static const double fontSize = 68;

  @override
  Widget build(BuildContext context) {
    final word = stroopColorName(round.targetWordId, context.l10n);
    return KeyedSubtree(
      key: ValueKey(round.identityKey),
      child: Text(
        word,
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
          .animate(key: ValueKey('stroop-enter-${round.identityKey}'))
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
