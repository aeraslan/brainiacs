import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/asteroid.dart';
import '../visual_colors.dart';
import 'asteroid_painter.dart';

class AsteroidSprite extends StatelessWidget {
  const AsteroidSprite({
    super.key,
    required this.asteroid,
    required this.isShaking,
    required this.shakeToken,
    required this.onTapped,
  });

  final Asteroid asteroid;
  final bool isShaking;
  final int shakeToken;
  final ValueChanged<int> onTapped;

  @override
  Widget build(BuildContext context) {
    final diameter = asteroid.radius * 2;
    final fontSize = (asteroid.radius * 0.42).clamp(12.0, 26.0).toDouble();

    Widget sprite = GestureDetector(
      onTap: asteroid.isPopped ? null : () => onTapped(asteroid.id),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Transform.rotate(
          angle: asteroid.angle,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: AsteroidPainter(
                    id: asteroid.id,
                    color: asteroid.color,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _AsteroidLabel(
                    text: asteroid.displayText,
                    fontSize: fontSize,
                    showOrientationHint: asteroid.needsOrientationHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (asteroid.isPopped) {
      sprite = sprite
          .animate(key: ValueKey('pop-${asteroid.id}'))
          .scale(
            begin: const Offset(1, 1),
            end: Offset.zero,
            duration: 280.ms,
            curve: Curves.easeIn,
          )
          .tint(color: AppColors.correct, duration: 200.ms);
    } else if (isShaking) {
      sprite = sprite
          .animate(key: ValueKey('shake-$shakeToken'))
          .shakeX(amount: 8, duration: 250.ms, hz: 6)
          .tint(color: AppColors.incorrect, duration: 200.ms);
    }

    return sprite;
  }
}

class _AsteroidLabel extends StatelessWidget {
  const _AsteroidLabel({
    required this.text,
    required this.fontSize,
    required this.showOrientationHint,
  });

  final String text;
  final double fontSize;
  final bool showOrientationHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VisualColors.label,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        if (showOrientationHint) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: fontSize * 0.62,
            height: 2.5,
            color: VisualColors.label,
          ),
        ],
      ],
    );
  }
}
