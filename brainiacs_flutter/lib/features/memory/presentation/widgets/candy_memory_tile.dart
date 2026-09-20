import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Glossy candy tile for Matrix Recall.
///
/// Face is isolated in [_CandyTileFace] so it can later be swapped for a
/// rabbit-in-hole visual without rewriting interaction or animation shell.
class CandyMemoryTile extends StatefulWidget {
  const CandyMemoryTile({
    super.key,
    required this.index,
    required this.isLit,
    required this.isWrong,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final bool isLit;
  final bool isWrong;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<CandyMemoryTile> createState() => _CandyMemoryTileState();
}

class _CandyMemoryTileState extends State<CandyMemoryTile> {
  @override
  void didUpdateWidget(CandyMemoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLit && widget.isLit) {
      HapticFeedback.lightImpact();
    }
    if (!oldWidget.isWrong && widget.isWrong) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isLit || widget.isWrong;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? widget.onTap : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: _CandyTileFace(
          index: widget.index,
          isLit: widget.isLit,
          isWrong: widget.isWrong,
        )
            .animate(target: active ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: active ? 120.ms : 180.ms,
              curve: active ? Curves.easeOut : Curves.easeIn,
            ),
      ),
    );
  }
}

class _CandyTileFace extends StatelessWidget {
  const _CandyTileFace({
    required this.index,
    required this.isLit,
    required this.isWrong,
  });

  final int index;
  final bool isLit;
  final bool isWrong;

  static const double _glossStop = 0.18;
  static const Color _dimStart = Color(0xFFD5D8DE);
  static const Color _dimEnd = Color(0xFF8A919C);
  static const Color _dimBorder = Color(0xFF6E7580);

  Color get _accent {
    final palette = AppColors.accentPalette;
    return palette[index % palette.length];
  }

  List<Color> get _gradientColors {
    if (isWrong) {
      return const [
        Color(0xFFFF8A9A),
        AppColors.incorrect,
        Color(0xFFC4001D),
      ];
    }
    if (isLit) {
      final accent = _accent;
      return [
        Color.lerp(Colors.white, accent, 0.25) ?? accent,
        accent,
        Color.lerp(accent, Colors.black, 0.28) ?? accent,
      ];
    }
    return const [_dimStart, _dimEnd];
  }

  Color get _borderColor {
    if (isWrong) {
      return const Color(0xFF9E0018);
    }
    if (isLit) {
      return Color.lerp(_accent, Colors.black, 0.35) ?? _accent;
    }
    return _dimBorder;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.md);
    final colors = _gradientColors;
    final stops = isLit || isWrong
        ? const [0.0, _glossStop, 0.55, 1.0]
        : const [0.0, _glossStop, 1.0];
    final gradientColors = isLit || isWrong
        ? [
            Colors.white.withValues(alpha: 0.7),
            colors[0],
            colors[1],
            colors[2],
          ]
        : [
            Colors.white.withValues(alpha: 0.45),
            colors[0],
            colors[1],
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: stops,
        ),
        border: Border.all(color: _borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: (isLit || isWrong)
                ? _borderColor.withValues(alpha: 0.35)
                : AppColors.shadow,
            blurRadius: isLit || isWrong ? 14 : 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md - 2),
            border: Border.all(
              color: Colors.white.withValues(alpha: isLit || isWrong ? 0.55 : 0.35),
              width: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}
