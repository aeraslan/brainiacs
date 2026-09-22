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
          );
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
            opacity: card.isMatched ? 0.92 : 1,
            child: isFrontVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      size: size,
                      assetPath: card.assetPath,
                      isFront: true,
                      isMatched: card.isMatched,
                    ),
                  )
                : _CardFace(
                    size: size,
                    isFront: false,
                    isMatched: false,
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
    required this.isMatched,
    this.assetPath,
  });

  final double size;
  final bool isFront;
  final bool isMatched;
  final String? assetPath;

  static const double _imagePadding = 12;
  static const double _glossStop = 0.18;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.sm);

    if (isMatched) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1DE06A),
              AppColors.correct,
              Color(0xFF009624),
            ],
          ),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.55),
              blurRadius: 0,
              spreadRadius: 1.5,
            ),
            const BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.25,
              ),
            ),
            child: CustomPaint(
              painter: _MatchedBorderOrnamentPainter(),
              child: _StickerImage(
                assetPath: assetPath,
                padding: _imagePadding,
              ),
            ),
          ),
        ),
      );
    }

    if (isFront) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF7F8FC),
              Color(0xFFE8ECF4),
            ],
            stops: [0.0, _glossStop, 1.0],
          ),
          border: Border.all(
            color: AppColors.electricBlue.withValues(alpha: 0.35),
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
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1.25,
              ),
            ),
            child: _StickerImage(
              assetPath: assetPath,
              padding: _imagePadding,
            ),
          ),
        ),
      );
    }

    // Face-down: candy glossy gradient with centered mark.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8C4FF),
            AppColors.vibrantPurple,
            Color(0xFF6B2FB5),
          ],
          stops: [0.0, _glossStop, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFF6B2FB5),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.vibrantPurple.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.25,
            ),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: math.max(size * 0.42, 22),
                fontWeight: FontWeight.w800,
                color: AppColors.onAccent.withValues(alpha: 0.95),
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerImage extends StatelessWidget {
  const _StickerImage({
    required this.assetPath,
    required this.padding,
  });

  final String? assetPath;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _MatchedBorderOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const inset = 7.0;
    const arm = 8.0;

    void corner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * arm, 0), paint);
      canvas.drawLine(origin, origin.translate(0, dy * arm), paint);
    }

    corner(const Offset(inset, inset), 1, 1);
    corner(Offset(size.width - inset, inset), -1, 1);
    corner(Offset(inset, size.height - inset), 1, -1);
    corner(Offset(size.width - inset, size.height - inset), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
