import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/memory_card.dart';
import '../card_match_notifier.dart';
import 'memory_card_tile.dart';

class CardMatchBoard extends StatelessWidget {
  const CardMatchBoard({
    super.key,
    required this.cards,
    required this.phase,
    required this.selectedCardIndices,
    required this.isEvaluating,
    required this.mismatchToken,
    required this.mismatchCardIndices,
    required this.onCardTapped,
    this.cardKeys,
  });

  final List<MemoryCard> cards;
  final CardMatchPhase phase;
  final List<int> selectedCardIndices;
  final bool isEvaluating;
  final int mismatchToken;
  final List<int> mismatchCardIndices;
  final ValueChanged<int> onCardTapped;
  final List<GlobalKey>? cardKeys;

  static const double _cardAspectRatio = 1.35;
  static const double _overflowPad = 14;

  GlobalKey? _keyForCard(int index) {
    final keys = cardKeys;
    if (keys == null || index < 0 || index >= keys.length) {
      return null;
    }
    return keys[index];
  }

  int _columnsForCount(int count) {
    if (count <= 4) {
      return 2;
    }
    if (count <= 6) {
      return 3;
    }
    if (count <= 8) {
      return 2;
    }
    if (count <= 12) {
      return 3;
    }
    return 4;
  }

  double _spacingForCount(int count) {
    if (count <= 6) {
      return AppSpacing.md;
    }
    if (count <= 12) {
      return AppSpacing.sm;
    }
    return AppSpacing.xs + 2;
  }

  double _cardSizeForLayout({
    required int count,
    required double maxWidth,
    required double maxHeight,
  }) {
    final columns = _columnsForCount(count);
    final rows = (count / columns).ceil();
    final spacing = _spacingForCount(count);

    final usableWidth = (maxWidth - _overflowPad * 2).clamp(0.0, maxWidth);
    final usableHeight = (maxHeight - _overflowPad * 2).clamp(0.0, maxHeight);

    final widthBudget =
        (usableWidth - spacing * (columns - 1)).clamp(0.0, usableWidth) /
        columns;
    final heightBudget =
        (usableHeight - spacing * (rows - 1)).clamp(0.0, usableHeight) / rows;
    final sizeFromHeight = heightBudget / _cardAspectRatio;

    return widthBudget < sizeFromHeight ? widthBudget : sizeFromHeight;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = _spacingForCount(cards.length);
        final cardSize = _cardSizeForLayout(
          count: cards.length,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        ).clamp(40.0, 120.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var index = 0; index < cards.length; index++)
                      MemoryCardTile(
                        key: _keyForCard(index),
                        card: cards[index],
                        size: cardSize,
                        onTap: () => onCardTapped(index),
                        isShaking:
                            isEvaluating &&
                            mismatchToken > 0 &&
                            mismatchCardIndices.contains(index),
                        shakeKey: mismatchToken,
                        isMatchJuice: cards[index].isMatched,
                        matchJuiceKey: cards[index].id,
                      ),
                  ],
                ),
              ),
            ),
            if (isEvaluating && mismatchToken > 0)
              Positioned(
                top: AppSpacing.sm,
                child:
                    Text(
                          'Wrong!',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.incorrect,
                                fontWeight: FontWeight.w800,
                              ),
                        )
                        .animate(key: ValueKey('wrong-$mismatchToken'))
                        .fadeIn(duration: 120.ms)
                        .slideY(begin: 0.2, end: 0, duration: 200.ms)
                        .then(delay: 200.ms)
                        .fadeOut(duration: 180.ms),
              ),
            if (phase == CardMatchPhase.memorize)
              Positioned(
                bottom: AppSpacing.sm,
                child: Text(
                  'Memorize the cards...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
