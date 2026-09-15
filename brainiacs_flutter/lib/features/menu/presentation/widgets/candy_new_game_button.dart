import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Glossy coral CTA used on the start screen.
class CandyNewGameButton extends StatelessWidget {
  const CandyNewGameButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  static const Color _gradientLight = Color(0xFFFF8E8E);
  static const Color _gradientDark = Color(0xFFE84E4E);
  static const Color _highlightBorder = Color(0x66FFFFFF);
  static const Color _softShadow = Color(0x33FF6B6B);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.md);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_gradientLight, AppColors.coral, _gradientDark],
              stops: [0.0, 0.45, 1.0],
            ),
            border: Border.all(color: _highlightBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: _softShadow,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md - 2),
                border: Border.all(
                  color: const Color(0x59FFFFFF),
                  width: 1.25,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    'New Game',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onAccent,
                      shadows: [
                        Shadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
