import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/session/game_session_state.dart';

class CircularTimer extends StatefulWidget {
  const CircularTimer({
    super.key,
    required this.timeRemaining,
    this.maxTime = GameSessionState.maxTimeLimit,
    this.size = 72,
    this.urgentThreshold = 10,
  });

  final int timeRemaining;
  final int maxTime;
  final double size;

  /// Seconds remaining at which the warning tilt starts.
  final int urgentThreshold;

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _urgencyController;
  late final Animation<double> _tilt;
  late final Animation<double> _pulse;

  bool get _isUrgent =>
      widget.timeRemaining > 0 &&
      widget.timeRemaining <= widget.urgentThreshold;

  @override
  void initState() {
    super.initState();
    _urgencyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _tilt = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.22), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.22, end: 0.22), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.22, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _urgencyController, curve: Curves.easeInOut),
    );
    _pulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _urgencyController, curve: Curves.easeOut),
    );

    if (_isUrgent) {
      _urgencyController.forward();
    }
  }

  @override
  void didUpdateWidget(CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeRemaining == oldWidget.timeRemaining) {
      return;
    }
    if (_isUrgent) {
      _urgencyController.forward(from: 0);
    } else {
      _urgencyController.reset();
    }
  }

  @override
  void dispose() {
    _urgencyController.dispose();
    super.dispose();
  }

  /// 0 = full time (green), 1 = time up (red).
  double get _urgency {
    if (widget.maxTime <= 0) {
      return 1;
    }
    return ((widget.maxTime - widget.timeRemaining) / widget.maxTime)
        .clamp(0.0, 1.0);
  }

  static Color colorForUrgency(double urgency) {
    if (urgency <= 0.45) {
      return Color.lerp(
        AppColors.correct,
        AppColors.sunnyYellow,
        urgency / 0.45,
      )!;
    }
    if (urgency <= 0.75) {
      return Color.lerp(
        AppColors.sunnyYellow,
        const Color(0xFFFF9100),
        (urgency - 0.45) / 0.3,
      )!;
    }
    return Color.lerp(
      const Color(0xFFFF9100),
      AppColors.incorrect,
      (urgency - 0.75) / 0.25,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final urgency = _urgency;
    final fillColor = colorForUrgency(urgency);
    final elapsedFraction = urgency;

    return AnimatedBuilder(
      animation: _urgencyController,
      builder: (context, child) {
        final tilt = _isUrgent ? _tilt.value : 0.0;
        final scale = _isUrgent ? _pulse.value : 1.0;

        return Transform.rotate(
          angle: tilt,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _CircularTimerPainter(
            elapsedFraction: elapsedFraction,
            fillColor: fillColor,
            isUrgent: _isUrgent,
          ),
          child: Center(
            child: Text(
              '${widget.timeRemaining}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onAccent,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: _isUrgent
                        ? const [
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  const _CircularTimerPainter({
    required this.elapsedFraction,
    required this.fillColor,
    required this.isUrgent,
  });

  final double elapsedFraction;
  final Color fillColor;
  final bool isUrgent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * elapsedFraction;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 2, fillPaint);

    if (elapsedFraction > 0) {
      final elapsedPaint = Paint()
        ..color = Color.lerp(fillColor, const Color(0xFF000000), 0.28)!
            .withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        true,
        elapsedPaint,
      );
    }

    final borderPaint = Paint()
      ..color = isUrgent
          ? Colors.white.withValues(alpha: 0.92)
          : AppColors.timerBorder.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isUrgent ? 3.5 : 3;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Soft remaining-time ring so progress stays readable on the shifting fill.
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: isUrgent ? 0.95 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final remainingSweep = 2 * math.pi * (1 - elapsedFraction);
    if (remainingSweep > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        startAngle + sweepAngle,
        remainingSweep,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.elapsedFraction != elapsedFraction ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.isUrgent != isUrgent;
  }
}
