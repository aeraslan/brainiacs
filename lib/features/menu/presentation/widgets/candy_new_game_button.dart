import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../shared/widgets/candy_button.dart';

/// Glossy mint CTA used on the start screen (matches Play Again).
class CandyNewGameButton extends StatelessWidget {
  const CandyNewGameButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CandyButton(
      label: context.l10n.menuNewGame,
      onPressed: onPressed,
      variant: CandyButtonVariant.primarySuccess,
    );
  }
}
