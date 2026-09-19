import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Glossy 3D pad key with tactile press scale (shared by number/operator pads).
class CandyPadButton extends StatefulWidget {
  const CandyPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.gradientColors,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.child,
    this.borderRadius,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  /// Optional glyph (icons/text). Centered in the button, independent of gloss.
  final Widget? child;

  /// Defaults to [AppSpacing.md]. Pass a large value (e.g. half the width) for a circle.
  final double? borderRadius;

  @override
  State<CandyPadButton> createState() => _CandyPadButtonState();
}

class _CandyPadButtonState extends State<CandyPadButton> {
  bool _pressed = false;

  static const double _glossStop = 0.18;

  List<Color> get _gradientColors {
    return widget.gradientColors ??
        const [AppColors.padGradientStart, AppColors.padGradientEnd];
  }

  Color get _borderColor => widget.borderColor ?? AppColors.padBorder;

  double get _radius => widget.borderRadius ?? AppSpacing.md;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(CandyPadButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _pressed) {
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapUp: widget.enabled
          ? (_) {
              _setPressed(false);
              widget.onPressed();
            }
          : null,
      onTapCancel: widget.enabled ? () => _setPressed(false) : null,
      child:
          DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_radius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      ..._gradientColors,
                    ],
                    stops: const [0.0, _glossStop, 1.0],
                  ),
                  border: Border.all(color: _borderColor, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [Center(child: _buildLabel(context))],
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

  Widget _buildLabel(BuildContext context) {
    final glyph =
        widget.child ??
        Text(
          widget.label,
          textAlign: TextAlign.center,
          textHeightBehavior: widget.fontSize == null
              ? null
              : const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.onAccent,
            fontWeight: widget.fontWeight ?? FontWeight.w800,
            fontSize: widget.fontSize,
            height: widget.fontSize == null ? null : 1,
            leadingDistribution: widget.fontSize == null
                ? null
                : TextLeadingDistribution.even,
          ),
        );

    if (widget.child == null && widget.fontSize == null) {
      return glyph;
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: glyph,
      ),
    );
  }
}
