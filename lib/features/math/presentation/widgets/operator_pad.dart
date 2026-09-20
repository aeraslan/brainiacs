import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/candy_pad_button.dart';
import '../../domain/math_equation.dart';

/// 2×2 candy operator pad: + − × /. Sized for large mobile hit targets.
class OperatorPad extends StatelessWidget {
  const OperatorPad({
    super.key,
    required this.onOperator,
    this.enabled = true,
    this.operatorKeys,
  });

  final ValueChanged<MathOperator> onOperator;
  final bool enabled;
  final Map<MathOperator, GlobalKey>? operatorKeys;

  static const double _lockedOpacity = 0.7;

  /// Fill most of the control width so side margins stay modest.
  static const double _widthFactor = 0.84;

  /// Use most of the control slot so cells can grow without going tall-narrow.
  static const double _heightFactor = 0.82;

  /// Slightly wide rounded-rect cells; never taller than they are wide.
  static const double _maxCellAspect = 1.15;

  /// Glyph size relative to the shorter cell side.
  static const double _symbolSizeFactor = 0.5;

  static const List<MathOperator> _order = [
    MathOperator.add,
    MathOperator.subtract,
    MathOperator.multiply,
    MathOperator.divide,
  ];

  static Color _colorFor(MathOperator op) {
    return switch (op) {
      MathOperator.add => AppColors.coral,
      MathOperator.subtract => AppColors.mint,
      MathOperator.multiply => AppColors.electricBlue,
      MathOperator.divide => AppColors.vibrantPurple,
    };
  }

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.md;
        const columns = 2;
        const rows = 2;

        var cellWidth =
            (constraints.maxWidth * _widthFactor - spacing * (columns - 1)) /
            columns;
        var cellHeight =
            (constraints.maxHeight * _heightFactor - spacing * (rows - 1)) /
            rows;

        if (cellWidth > cellHeight * _maxCellAspect) {
          cellWidth = cellHeight * _maxCellAspect;
        } else if (cellWidth < cellHeight) {
          cellHeight = cellWidth;
        }

        cellWidth = math.max(0, cellWidth);
        cellHeight = math.max(0, cellHeight);

        final padWidth = cellWidth * columns + spacing * (columns - 1);
        final padHeight = cellHeight * rows + spacing * (rows - 1);
        final symbolSize = math.min(cellWidth, cellHeight) * _symbolSizeFactor;

        Widget button(MathOperator op) {
          final color = _colorFor(op);
          return KeyedSubtree(
            key: operatorKeys?[op],
            child: CandyPadButton(
              label: op.symbol,
              enabled: enabled,
              fontSize: symbolSize,
              fontWeight: FontWeight.w700,
              gradientColors: [color, _darken(color)],
              borderColor: _darken(color),
              onPressed: () => onOperator(op),
              child: _OperatorGlyph(operator: op, size: symbolSize),
            ),
          );
        }

        Widget row(List<MathOperator> ops) {
          return SizedBox(
            height: cellHeight,
            child: Row(
              children: [
                for (var i = 0; i < ops.length; i++) ...[
                  if (i > 0) const SizedBox(width: spacing),
                  Expanded(child: button(ops[i])),
                ],
              ],
            ),
          );
        }

        final pad = SizedBox(
          width: padWidth,
          height: padHeight,
          child: Column(
            children: [
              row(_order.sublist(0, 2)),
              const SizedBox(height: spacing),
              row(_order.sublist(2, 4)),
            ],
          ),
        );

        return Opacity(
          opacity: enabled ? 1 : _lockedOpacity,
          child: Align(alignment: Alignment.center, child: pad),
        );
      },
    );
  }
}

/// Optically centered operator marks. Multiply uses Icons.close (×), not 'x'.
class _OperatorGlyph extends StatelessWidget {
  const _OperatorGlyph({required this.operator, required this.size});

  final MathOperator operator;
  final double size;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.onAccent;
    return switch (operator) {
      MathOperator.add => Icon(Icons.add, size: size, color: color),
      MathOperator.subtract => Icon(Icons.remove, size: size, color: color),
      MathOperator.multiply => Icon(Icons.close, size: size, color: color),
      MathOperator.divide => Text(
        '/',
        textAlign: TextAlign.center,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
    };
  }
}
