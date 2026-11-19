import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/l10n_extension.dart';

/// Soft candy gear button for opening Settings from the main menu.
class SettingsIconButton extends StatefulWidget {
  const SettingsIconButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  State<SettingsIconButton> createState() => _SettingsIconButtonState();
}

class _SettingsIconButtonState extends State<SettingsIconButton> {
  bool _pressed = false;

  static final Color _fill = Color.lerp(AppColors.electricBlue, Colors.white, 0.88)!;
  static const Color _softShadow = Color(0x3345B7D1);

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = context.l10n.menuSettingsTooltip;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _fill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.electricBlue,
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
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.settings_rounded,
                  color: AppColors.electricBlue,
                  size: AppSpacing.lg,
                ),
              ),
            )
                .animate(target: _pressed ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.92, 0.92),
                  duration: _pressed ? 90.ms : 220.ms,
                  curve: _pressed ? Curves.easeOut : Curves.elasticOut,
                ),
          ),
        ),
      ),
    );
  }
}
