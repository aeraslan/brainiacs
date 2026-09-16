import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';

/// Celebratory sunburst + popping stars behind the score.
class EndMatchCelebration extends StatelessWidget {
  const EndMatchCelebration({super.key});

  static const List<_ParticleSpec> _particles = [
    _ParticleSpec(
      alignment: Alignment(-0.55, -0.35),
      size: 14,
      color: AppColors.sunnyYellow,
      delayMs: 80,
    ),
    _ParticleSpec(
      alignment: Alignment(0.5, -0.4),
      size: 12,
      color: AppColors.coral,
      delayMs: 140,
    ),
    _ParticleSpec(
      alignment: Alignment(-0.7, 0.05),
      size: 10,
      color: AppColors.mint,
      delayMs: 200,
    ),
    _ParticleSpec(
      alignment: Alignment(0.65, -0.05),
      size: 16,
      color: AppColors.electricBlue,
      delayMs: 100,
    ),
    _ParticleSpec(
      alignment: Alignment(-0.35, -0.55),
      size: 11,
      color: AppColors.vibrantPurple,
      delayMs: 180,
    ),
    _ParticleSpec(
      alignment: Alignment(0.3, -0.6),
      size: 13,
      color: AppColors.sunnyYellow,
      delayMs: 240,
    ),
    _ParticleSpec(
      alignment: Alignment(-0.15, -0.2),
      size: 8,
      color: AppColors.coral,
      delayMs: 60,
    ),
    _ParticleSpec(
      alignment: Alignment(0.2, -0.15),
      size: 9,
      color: AppColors.mint,
      delayMs: 160,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: const CustomPaint(
                  painter: _SunburstPainter(),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .rotate(
                      begin: -0.08,
                      end: 0.04,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            ),
            for (final particle in _particles)
              Align(
                alignment: particle.alignment,
                child: _StarParticle(
                  size: particle.size,
                  color: particle.color,
                )
                    .animate()
                    .fadeIn(
                      delay: particle.delayMs.ms,
                      duration: 280.ms,
                    )
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      delay: particle.delayMs.ms,
                      duration: 420.ms,
                      curve: Curves.easeOutBack,
                    )
                    .moveY(
                      begin: 12,
                      end: -8,
                      delay: particle.delayMs.ms,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ParticleSpec {
  const _ParticleSpec({
    required this.alignment,
    required this.size,
    required this.color,
    required this.delayMs,
  });

  final Alignment alignment;
  final double size;
  final Color color;
  final int delayMs;
}

class _StarParticle extends StatelessWidget {
  const _StarParticle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StarPainter(color: color),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  const _SunburstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    const rayCount = 16;

    for (var i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * math.pi * 2;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angle - 0.08) * radius,
          center.dy + math.sin(angle - 0.08) * radius,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.08) * radius,
          center.dy + math.sin(angle + 0.08) * radius,
        )
        ..close();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.sunnyYellow.withValues(alpha: 0.35),
            AppColors.coral.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawPath(path, paint);
    }

    canvas.drawCircle(
      center,
      radius * 0.28,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.55),
            AppColors.sunnyYellow.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.28)),
    );
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.4;

    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final angle = (i * math.pi / 5) - math.pi / 2;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}
