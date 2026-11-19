import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/l10n_extension.dart';

/// Compact candy pill that opens My Progress from the main menu.
class MyProgressPillButton extends StatefulWidget {
  const MyProgressPillButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  State<MyProgressPillButton> createState() => _MyProgressPillButtonState();
}

class _MyProgressPillButtonState extends State<MyProgressPillButton> {
  bool _pressed = false;

  static final Color _fill = Color.lerp(AppColors.mint, Colors.white, 0.9)!;
  static const Color _softShadow = Color(0x334ECDC4);

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.menuMyProgress;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _fill,
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              border: Border.all(
                color: AppColors.mint,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: _softShadow,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.mint,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                      size: 18,
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
              end: const Offset(0.94, 0.94),
              duration: _pressed ? 90.ms : 220.ms,
              curve: _pressed ? Curves.easeOut : Curves.elasticOut,
            ),
      ),
    );
  }
}
