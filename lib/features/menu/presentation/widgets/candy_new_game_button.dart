import 'package:flutter/material.dart';

import '../../../../shared/widgets/candy_button.dart';

/// Glossy coral CTA used on the start screen.
class CandyNewGameButton extends StatelessWidget {
  const CandyNewGameButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CandyButton(
      label: 'New Game',
      onPressed: onPressed,
      variant: CandyButtonVariant.primary,
    );
  }
}
