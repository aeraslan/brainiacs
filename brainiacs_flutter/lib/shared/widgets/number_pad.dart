import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Shared candy-style digit pad. Error juice lives elsewhere (e.g. score HUD);
/// this widget only provides glossy keys, press pop, and a lockout dim.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onClear,
    this.enabled = true,
    this.digitKeys,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onClear;

  /// When false (parent feedback lockout), ignores taps and dims to 0.7.
  final bool enabled;
  final Map<int, GlobalKey>? digitKeys;

  static const double _lockedOpacity = 0.7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        const rows = 4;
        final cellHeight =
            (constraints.maxHeight - spacing * (rows - 1)) / rows;

        Widget digitButton(int digit) {
          return KeyedSubtree(
            key: digitKeys?[digit],
            child: _PadButton(
              label: '$digit',
              enabled: enabled,
              onPressed: () => onDigit(digit),
            ),
          );
        }

        Widget row(List<Widget> children) {
          return SizedBox(
            height: cellHeight,
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: spacing),
                  Expanded(child: children[i]),
                ],
              ],
            ),
          );
        }

        final pad = Column(
          children: [
            row([digitButton(1), digitButton(2), digitButton(3)]),
            const SizedBox(height: spacing),
            row([digitButton(4), digitButton(5), digitButton(6)]),
            const SizedBox(height: spacing),
            row([digitButton(7), digitButton(8), digitButton(9)]),
            const SizedBox(height: spacing),
            row([
              const SizedBox.shrink(),
              digitButton(0),
              _PadButton(
                label: 'C',
                enabled: enabled,
                isClear: true,
                onPressed: onClear,
              ),
            ]),
          ],
        );

        return Opacity(
          opacity: enabled ? 1 : _lockedOpacity,
          child: pad,
        );
      },
    );
  }
}

class _PadButton extends StatefulWidget {
  const _PadButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isClear = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isClear;

  @override
  State<_PadButton> createState() => _PadButtonState();
}

class _PadButtonState extends State<_PadButton> {
  bool _pressed = false;

  List<Color> get _gradientColors {
    if (widget.isClear) {
      return [
        AppColors.incorrect.withValues(alpha: 0.95),
        AppColors.incorrect.withValues(alpha: 0.75),
      ];
    }
    return const [
      AppColors.padGradientStart,
      AppColors.padGradientEnd,
    ];
  }

  Color get _borderColor =>
      widget.isClear ? AppColors.incorrect : AppColors.padBorder;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(_PadButton oldWidget) {
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.55),
              ..._gradientColors,
            ],
            stops: const [0.0, 0.18, 1.0],
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
        child: Center(
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.w800,
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
