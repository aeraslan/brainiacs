import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

enum CandyButtonVariant {
  primary,
  secondary,
  green,

  /// Mint/teal primary CTA for positive actions (e.g. Play Again).
  primarySuccess,

  /// Quieter purple secondary CTA (e.g. Menu on the score screen).
  secondarySoft,
}

/// Glossy 3D candy CTA with tactile press scale.
class CandyButton extends StatefulWidget {
  const CandyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CandyButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final CandyButtonVariant variant;

  /// Optional leading icon (e.g. replay). Null keeps text-only layout.
  final IconData? icon;

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

  static const Color _greenLight = Color(0xFF7DFFB0);
  static const Color _greenMid = Color(0xFF2EE56A);
  static const Color _greenDark = Color(0xFF12B84A);
  static const Color _greenSoftShadow = Color(0x332EE56A);

  // Bright minty-green primary CTA (New Game / Play Again).
  static const Color _successLight = Color(0xFF4AF0C8);
  static const Color _successMid = Color(0xFF26D9B0);
  static const Color _successDark = Color(0xFF14B89A);
  static const Color _successSoftShadow = Color(0x4026D9B0);

  // Narrower, duller purple than [secondary]; lightest stop ≥4.5:1 on white.
  static const Color _secondarySoftLight = Color(0xFF8A4FD0);
  static const Color _secondarySoftMid = Color(0xFF7640BC);
  static const Color _secondarySoftDark = Color(0xFF5E3499);
  static const Color _secondarySoftShadowColor = Color(0x229B5DE5);

  static const Color _highlightBorder = Color(0x66FFFFFF);
  static const Color _innerHighlight = Color(0x59FFFFFF);

  static const TextStyle _labelStyle = TextStyle(
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
  );

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
      CandyButtonVariant.green => const [
        _greenLight,
        _greenMid,
        _greenDark,
      ],
      CandyButtonVariant.primarySuccess => const [
        _successLight,
        _successMid,
        _successDark,
      ],
      CandyButtonVariant.secondarySoft => const [
        _secondarySoftLight,
        _secondarySoftMid,
        _secondarySoftDark,
      ],
    };
  }

  Color get _softShadow {
    return switch (widget.variant) {
      CandyButtonVariant.primary => _primarySoftShadow,
      CandyButtonVariant.secondary => _secondarySoftShadow,
      CandyButtonVariant.green => _greenSoftShadow,
      CandyButtonVariant.primarySuccess => _successSoftShadow,
      CandyButtonVariant.secondarySoft => _secondarySoftShadowColor,
    };
  }

  double get _accentShadowBlur {
    return switch (widget.variant) {
      CandyButtonVariant.primarySuccess => 20,
      CandyButtonVariant.secondarySoft => 10,
      _ => 16,
    };
  }

  Offset get _accentShadowOffset {
    return switch (widget.variant) {
      CandyButtonVariant.primarySuccess => const Offset(0, 8),
      CandyButtonVariant.secondarySoft => const Offset(0, 4),
      _ => const Offset(0, 8),
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
    final icon = widget.icon;

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
                blurRadius: _accentShadowBlur,
                offset: _accentShadowOffset,
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
                  child: icon == null
                      ? Text(widget.label, style: _labelStyle)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              color: AppColors.onAccent,
                              size: 20,
                              shadows: const [
                                Shadow(
                                  color: Color(0x33000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(widget.label, style: _labelStyle),
                          ],
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
