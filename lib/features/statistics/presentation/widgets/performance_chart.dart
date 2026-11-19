import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/score_format.dart';
import '../../application/player_statistics_provider.dart';
import '../../domain/game_session_record.dart';
import '../../domain/performance_chart_scale.dart';

/// Lightweight CustomPainter chart of recent New Game session scores.
class PerformanceChart extends ConsumerWidget {
  const PerformanceChart({super.key});

  static const double chartHeight = 188;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(
      playerStatisticsProvider.select((s) => s.recentSessions),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.progressRecentPerformance,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          const _EmptyHistoryMessage()
        else
          _ChartCard(
            sessions: recent,
            reduceMotion: reduceMotion,
            runLabelForIndex: (index) =>
                context.l10n.progressRunLabel(index + 1),
            scoreLocale: locale,
          ),
      ],
    );
  }
}

class _EmptyHistoryMessage extends StatelessWidget {
  const _EmptyHistoryMessage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(
          color: AppColors.vibrantPurple.withValues(alpha: 0.28),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.vibrantPurple.withValues(alpha: 0.12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm + 2),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.vibrantPurple,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.progressEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.progressEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.sessions,
    required this.reduceMotion,
    required this.runLabelForIndex,
    required this.scoreLocale,
  });

  final List<GameSessionRecord> sessions;
  final bool reduceMotion;
  final String Function(int zeroBasedIndex) runLabelForIndex;
  final String scoreLocale;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(
          color: AppColors.vibrantPurple.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: SizedBox(
          height: PerformanceChart.chartHeight,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _PerformanceChartPainter(
                scores: [
                  for (final session in sessions) session.totalScore,
                ],
                runLabelForIndex: runLabelForIndex,
                scoreLocale: scoreLocale,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    if (reduceMotion) {
      return card;
    }

    return card
        .animate()
        .fadeIn(delay: 160.ms, duration: 320.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          delay: 160.ms,
          duration: 360.ms,
          curve: Curves.easeOut,
        );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  _PerformanceChartPainter({
    required this.scores,
    required this.runLabelForIndex,
    required this.scoreLocale,
  });

  final List<int> scores;
  final String Function(int zeroBasedIndex) runLabelForIndex;
  final String scoreLocale;

  static const Color lineColor = AppColors.vibrantPurple;
  static const double leftGutter = 52;
  static const double bottomGutter = 28;
  static const double topGutter = 12;
  static const double rightGutter = 12;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) {
      return;
    }

    final chartWidth = size.width - leftGutter - rightGutter;
    final chartHeight = size.height - topGutter - bottomGutter;
    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final yMax = PerformanceChartScale.yMaxFor(maxScore);
    final yTicks = PerformanceChartScale.yTicks(yMax);
    final xLabelIndices =
        PerformanceChartScale.visibleXLabelIndices(scores.length);

    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
      fontSize: 11,
    );

    for (final tick in yTicks) {
      final fraction = tick / yMax;
      final y = topGutter + chartHeight * (1 - fraction);
      canvas.drawLine(
        Offset(leftGutter, y),
        Offset(size.width - rightGutter, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: formatScore(tick, locale: scoreLocale),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: leftGutter - 4);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    Offset pointFor(int index, int score) {
      final xFraction =
          scores.length == 1 ? 0.5 : index / (scores.length - 1);
      final yFraction = (score / yMax).clamp(0.0, 1.0);
      return Offset(
        leftGutter + chartWidth * xFraction,
        topGutter + chartHeight * (1 - yFraction),
      );
    }

    final points = <Offset>[
      for (var i = 0; i < scores.length; i++) pointFor(i, scores[i]),
    ];

    if (points.length > 1) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, topGutter + chartHeight)
        ..lineTo(points.first.dx, topGutter + chartHeight)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.28),
              lineColor.withValues(alpha: 0.02),
            ],
          ).createShader(
            Rect.fromLTWH(leftGutter, topGutter, chartWidth, chartHeight),
          ),
      );
    }

    final dotPaint = Paint()..color = lineColor;
    final whitePaint = Paint()..color = Colors.white;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final isLatest = i == points.length - 1;
      final radius = isLatest ? 6.0 : 4.0;
      canvas.drawCircle(point, radius + 1.5, whitePaint);
      canvas.drawCircle(point, radius, dotPaint);
    }

    final xLabelStyle = TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.95),
      fontWeight: FontWeight.w700,
      fontSize: 11,
    );
    for (final index in xLabelIndices) {
      final point = points[index];
      final tp = TextPainter(
        text: TextSpan(
          text: runLabelForIndex(index),
          style: xLabelStyle,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final x = (point.dx - tp.width / 2)
          .clamp(leftGutter - 4, size.width - rightGutter - tp.width);
      tp.paint(canvas, Offset(x, size.height - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PerformanceChartPainter oldDelegate) {
    if (scoreLocale != oldDelegate.scoreLocale) {
      return true;
    }
    if (identical(scores, oldDelegate.scores)) {
      return false;
    }
    if (scores.length != oldDelegate.scores.length) {
      return true;
    }
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] != oldDelegate.scores[i]) {
        return true;
      }
    }
    return false;
  }
}
