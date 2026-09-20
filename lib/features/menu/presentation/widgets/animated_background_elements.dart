import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'decor_asteroid.dart';
import 'decor_isometric_cube.dart';
import 'floating_decor_item.dart';

/// Candy-pastel floating cubes, asteroids, and math symbols for the start screen.
class AnimatedBackgroundElements extends StatelessWidget {
  const AnimatedBackgroundElements({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CandyWash(),
            // Cubes
            FloatingDecorItem(
              alignment: Alignment(-0.82, -0.55),
              delay: Duration(milliseconds: 0),
              floatDuration: Duration(milliseconds: 4800),
              rotateDuration: Duration(milliseconds: 12000),
              floatOffset: 12,
              rotateTurns: 0.12,
              child: DecorIsometricCube(
                color: Color(0x99FF6B6B),
                size: 72,
              ),
            ),
            FloatingDecorItem(
              alignment: Alignment(0.78, -0.35),
              delay: Duration(milliseconds: 600),
              floatDuration: Duration(milliseconds: 5200),
              rotateDuration: Duration(milliseconds: 14000),
              floatOffset: 16,
              rotateTurns: 0.1,
              opacityBegin: 0.18,
              opacityEnd: 0.3,
              child: DecorIsometricCube(
                color: Color(0x9945B7D1),
                size: 54,
              ),
            ),
            FloatingDecorItem(
              alignment: Alignment(-0.55, 0.62),
              delay: Duration(milliseconds: 1100),
              floatDuration: Duration(milliseconds: 4500),
              rotateDuration: Duration(milliseconds: 10000),
              floatOffset: 10,
              rotateTurns: 0.09,
              child: DecorIsometricCube(
                color: Color(0x999B5DE5),
                size: 63,
              ),
            ),
            // Asteroids
            FloatingDecorItem(
              alignment: Alignment(0.72, 0.48),
              delay: Duration(milliseconds: 300),
              floatDuration: Duration(milliseconds: 5600),
              rotateDuration: Duration(milliseconds: 13000),
              floatOffset: 15,
              rotateTurns: 0.15,
              opacityBegin: 0.16,
              opacityEnd: 0.28,
              child: DecorAsteroid(
                id: 1,
                color: Color(0x884ECDC4),
                size: 66,
              ),
            ),
            FloatingDecorItem(
              alignment: Alignment(-0.75, 0.15),
              delay: Duration(milliseconds: 900),
              floatDuration: Duration(milliseconds: 5000),
              rotateDuration: Duration(milliseconds: 11500),
              floatOffset: 13,
              rotateTurns: 0.11,
              child: DecorAsteroid(
                id: 2,
                color: Color(0x88FFE66D),
                size: 51,
              ),
            ),
            FloatingDecorItem(
              alignment: Alignment(0.15, -0.72),
              delay: Duration(milliseconds: 1400),
              floatDuration: Duration(milliseconds: 4300),
              rotateDuration: Duration(milliseconds: 9000),
              floatOffset: 11,
              rotateTurns: 0.14,
              opacityBegin: 0.15,
              opacityEnd: 0.26,
              child: DecorAsteroid(
                id: 3,
                color: Color(0x88FF6B6B),
                size: 45,
              ),
            ),
            // Math symbols
            FloatingDecorItem(
              alignment: Alignment(0.55, -0.68),
              delay: Duration(milliseconds: 200),
              floatDuration: Duration(milliseconds: 4000),
              rotateDuration: Duration(milliseconds: 8500),
              floatOffset: 10,
              rotateTurns: 0.06,
              opacityBegin: 0.2,
              opacityEnd: 0.34,
              child: _MathSymbol('+', color: AppColors.coral, fontSize: 54),
            ),
            FloatingDecorItem(
              alignment: Alignment(-0.35, -0.28),
              delay: Duration(milliseconds: 750),
              floatDuration: Duration(milliseconds: 4600),
              rotateDuration: Duration(milliseconds: 9500),
              floatOffset: 12,
              rotateTurns: 0.07,
              child: _MathSymbol('−', color: AppColors.mint, fontSize: 60),
            ),
            FloatingDecorItem(
              alignment: Alignment(0.88, 0.05),
              delay: Duration(milliseconds: 450),
              floatDuration: Duration(milliseconds: 5100),
              rotateDuration: Duration(milliseconds: 10500),
              floatOffset: 14,
              rotateTurns: 0.05,
              opacityBegin: 0.18,
              opacityEnd: 0.3,
              child: _MathSymbol('×', color: AppColors.vibrantPurple, fontSize: 51),
            ),
            FloatingDecorItem(
              alignment: Alignment(-0.1, 0.55),
              delay: Duration(milliseconds: 1250),
              floatDuration: Duration(milliseconds: 4700),
              rotateDuration: Duration(milliseconds: 12500),
              floatOffset: 11,
              rotateTurns: 0.08,
              child: _MathSymbol('÷', color: AppColors.electricBlue, fontSize: 57),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandyWash extends StatelessWidget {
  const _CandyWash();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4F6F9),
              Color(0x22FFE66D),
              Color(0x184ECDC4),
              Color(0x18FF6B6B),
              Color(0xFFF4F6F9),
            ],
            stops: [0.0, 0.28, 0.52, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class _MathSymbol extends StatelessWidget {
  const _MathSymbol(
    this.symbol, {
    required this.color,
    this.fontSize = 36,
  });

  final String symbol;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      symbol,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color.withValues(alpha: 0.55),
        height: 1,
      ),
    );
  }
}
