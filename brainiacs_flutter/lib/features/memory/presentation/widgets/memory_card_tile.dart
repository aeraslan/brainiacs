import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/memory_card.dart';

class MemoryCardTile extends StatelessWidget {
  const MemoryCardTile({
    super.key,
    required this.card,
    required this.size,
    required this.onTap,
    required this.isShaking,
    required this.shakeKey,
    required this.isMatchJuice,
    required this.matchJuiceKey,
  });

  final MemoryCard card;
  final double size;
  final VoidCallback onTap;
  final bool isShaking;
  final int shakeKey;
  final bool isMatchJuice;
  final int matchJuiceKey;

  static const Duration flipDuration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    Widget tile = Transform.translate(
      offset: card.offset,
      child: Transform.rotate(
        angle: card.rotationRadians,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size * 1.35,
            child: _FlippingCard(
              card: card,
              size: size,
            ),
          ),
        ),
      ),
    );

    if (isMatchJuice) {
      tile = tile
          .animate(key: ValueKey('match-$matchJuiceKey-${card.id}'))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 120.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.08, 1.08),
            end: const Offset(1, 1),
            duration: 120.ms,
          )
          .tint(color: AppColors.correct, duration: 200.ms);
    } else if (isShaking) {
      tile = tile
          .animate(key: ValueKey('shake-$shakeKey-${card.id}'))
          .shakeX(amount: 8, duration: 250.ms, hz: 6)
          .tint(color: AppColors.incorrect, duration: 200.ms);
    }

    return tile;
  }
}

class _FlippingCard extends StatelessWidget {
  const _FlippingCard({
    required this.card,
    required this.size,
  });

  final MemoryCard card;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: card.isFaceUp ? math.pi : 0),
      duration: MemoryCardTile.flipDuration,
      curve: Curves.easeInOut,
      builder: (context, angle, child) {
        final isFrontVisible = angle >= math.pi / 2;
        final displayAngle = isFrontVisible ? angle - math.pi : angle;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(displayAngle),
          child: Opacity(
            opacity: card.isMatched ? 0.72 : 1,
            child: isFrontVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      size: size,
                      icon: card.icon,
                      isFront: true,
                    ),
                  )
                : _CardFace(
                    size: size,
                    isFront: false,
                  ),
          ),
        );
      },
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.size,
    required this.isFront,
    this.icon,
  });

  final double size;
  final bool isFront;
  final IconData? icon;

  Color _iconColor(IconData iconData) {
    return AppColors.accentPalette[
        iconData.hashCode.abs() % AppColors.accentPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        color: isFront ? AppColors.surface : AppColors.vibrantPurple,
        border: Border.all(
          color: isFront
              ? AppColors.electricBlue.withValues(alpha: 0.4)
              : AppColors.vibrantPurple,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isFront
          ? Center(
              child: Icon(
                icon,
                size: size * 0.45,
                color: icon != null ? _iconColor(icon!) : AppColors.accent,
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CardBackPatternPainter(),
                  ),
                ),
                Icon(
                  Icons.psychology_rounded,
                  size: size * 0.4,
                  color: AppColors.onAccent,
                ),
              ],
            ),
    );
  }
}

class _CardBackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onAccent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 12.0;
    for (var x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
