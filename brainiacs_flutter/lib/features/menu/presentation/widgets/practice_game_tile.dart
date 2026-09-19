import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Glossy 3D level-selector badge for the Practice Menu grid.
class PracticeGameTile extends StatefulWidget {
  const PracticeGameTile({
    super.key,
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.softShadowColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color softShadowColor;
  final VoidCallback onPressed;

  @override
  State<PracticeGameTile> createState() => _PracticeGameTileState();
}

class _PracticeGameTileState extends State<PracticeGameTile> {
  static const Color _highlightBorder = Color(0x66FFFFFF);
  static const Color _innerHighlight = Color(0x59FFFFFF);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.lg);
    final innerRadius = BorderRadius.circular(AppSpacing.lg - 2);

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) {
          _setPressed(false);
          widget.onPressed();
        },
        onTapCancel: () => _setPressed(false),
        child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.55),
                    ...widget.gradientColors,
                  ],
                  stops: const [0.0, 0.18, 0.55, 1.0],
                ),
                border: Border.all(color: _highlightBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.softShadowColor,
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
                    borderRadius: innerRadius,
                    border: Border.all(color: _innerHighlight, width: 1.25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              widget.icon,
                              size: AppSpacing.xxl * 2,
                              color: AppColors.onAccent,
                              shadows: const [
                                Shadow(
                                  color: Color(0x33000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
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
                      ],
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
      ),
    );
  }
}
