import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/balance_puzzle.dart';
import 'candy_scale.dart';

/// Layouts Balance Logic scales: L1 one scale, L2 two independent, L3/L4 tree.
///
/// Always fits the parent via [FittedBox] so boards never BOTTOM OVERFLOW.
/// All scales use the same slate candy color so assets pop.
class BalanceBoard extends StatelessWidget {
  const BalanceBoard({
    super.key,
    required this.puzzle,
  });

  final BalancePuzzle puzzle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: switch (puzzle.level) {
                BalanceLevel.one => _buildLevelOne(constraints),
                BalanceLevel.two => _buildTwoScales(constraints),
                BalanceLevel.three || BalanceLevel.four =>
                  _buildTree(constraints),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelOne(BoxConstraints constraints) {
    final width = (constraints.maxWidth * 0.72).clamp(160.0, 280.0);
    final objectSize = (width * 0.22).clamp(48.0, 64.0);

    return CandyScale(
      key: ValueKey(puzzle.identityKey),
      comparison: puzzle.scales.first,
      objectSize: objectSize,
      scaleWidth: width,
    );
  }

  Widget _buildTwoScales(BoxConstraints constraints) {
    final gap = AppSpacing.md;
    final width = ((constraints.maxWidth - gap) / 2).clamp(120.0, 200.0);
    final objectSize = (width * 0.24).clamp(40.0, 56.0);

    return Row(
      key: ValueKey(puzzle.identityKey),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CandyScale(
          comparison: puzzle.scales[0],
          objectSize: objectSize,
          scaleWidth: width,
        ),
        SizedBox(width: gap),
        CandyScale(
          comparison: puzzle.scales[1],
          objectSize: objectSize,
          scaleWidth: width,
        ),
      ],
    );
  }

  Widget _buildTree(BoxConstraints constraints) {
    final gap = AppSpacing.sm;
    final topWidth = ((constraints.maxWidth - gap) / 2).clamp(110.0, 170.0);
    final bottomWidth = (constraints.maxWidth * 0.52).clamp(130.0, 190.0);
    final topObject = (topWidth * 0.2).clamp(36.0, 48.0);
    final bottomObject = (bottomWidth * 0.2).clamp(36.0, 52.0);

    return Column(
      key: ValueKey(puzzle.identityKey),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CandyScale(
              comparison: puzzle.scales[0],
              objectSize: topObject,
              scaleWidth: topWidth,
            ),
            SizedBox(width: gap),
            CandyScale(
              comparison: puzzle.scales[1],
              objectSize: topObject,
              scaleWidth: topWidth,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        CandyScale(
          comparison: puzzle.scales[2],
          objectSize: bottomObject,
          scaleWidth: bottomWidth,
        ),
      ],
    );
  }
}
