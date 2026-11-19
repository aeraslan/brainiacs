import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Compact candy-themed switch row for Settings and the Pause menu.
class CandySwitchRow extends StatelessWidget {
  const CandySwitchRow({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final descriptionText = description;

    return MergeSemantics(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(AppSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? AppSpacing.sm : AppSpacing.md,
                vertical: compact ? AppSpacing.sm : AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.electricBlue,
                    size: compact ? 22 : 24,
                  ),
                  SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: compact ? 15 : null,
                          ),
                        ),
                        if (descriptionText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            descriptionText,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: AppColors.onAccent,
                    activeTrackColor: AppColors.mint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
