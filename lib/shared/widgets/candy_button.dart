import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

enum CandyButtonVariant { primary, secondary }

/// Glossy 3D candy CTA with tactile press scale.
class CandyButton extends StatefulWidget {
  const CandyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CandyButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final CandyButtonVariant variant;

  @override
  State<CandyButton> createState() => _CandyButtonState();
}

class _CandyButtonState extends State<CandyButton> {
  bool _pressed = false;

  static const Color _primaryLight = Color(0xFFFF8E8E);
  static const Color _primaryDark = Color(0xFFE84E4E);
  static const Color _primarySoftShadow = Color(0x33FF6B6B);

  static const Color _secondaryLight = Color(0xFFB57AEE);
  static const Color _secondaryDark = Color(0xFF7A45C4);
  static const Color _secondarySoftShadow = Color(0x339B5DE5);

  static const Color _highlightBorder = Color(0x66FFFFFF);
  static const Color _innerHighlight = Color(0x59FFFFFF);

  List<Color> get _gradientColors {
    return switch (widget.variant) {
      CandyButtonVariant.primary => const [
        _primaryLight,
        AppColors.coral,
        _primaryDark,
      ],
      CandyButtonVariant.secondary => const [
        _secondaryLight,
        AppColors.vibrantPurple,
        _secondaryDark,
      ],
    };
  }

  Color get _softShadow {
    return switch (widget.variant) {
      CandyButtonVariant.primary => _primarySoftShadow,
      CandyButtonVariant.secondary => _secondarySoftShadow,
    };
  }

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.md);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _gradientColors,
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(color: _highlightBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _softShadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
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
                border: Border.all(color: _innerHighlight, width: 1.25),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
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
      )
          .animate(target: _pressed ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.9, 0.9),
            duration: _pressed ? 90.ms : 220.ms,
            curve: _pressed ? Curves.easeOut : Curves.elasticOut,
          ),
    );
  }
}
