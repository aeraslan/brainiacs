import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'orbital_rings_painter.dart';

/// Continuously animates [OrbitalRingsPainter] with a soothing parallax loop.
///
/// [speed] scales the base tempo (`1.0` = default ~20s cycle). Bind from
/// Riverpod later, e.g. `speed: mapSessionToWaveSpeed(ref.watch(...))`.
///
/// Phase is accumulated in continuous cycles (not wrapped 0→1) so fractional
/// parallax layer speeds never jump when a controller would repeat.
class AnimatedOrbitalRings extends StatefulWidget {
  const AnimatedOrbitalRings({
    super.key,
    required this.ringColor,
    this.speed = 1.0,
    this.initialPhase = 0,
  });

  final Color ringColor;

  /// Relative tempo multiplier. Values are clamped to `[0.25, 4.0]`.
  final double speed;

  /// Starting phase in cycles. Use to continue motion across widget remounts
  /// (e.g. countdown → dissolve overlay).
  final double initialPhase;

  static const Duration baseDuration = Duration(seconds: 20);
  static const double minSpeed = 0.25;
  static const double maxSpeed = 4.0;

  @override
  AnimatedOrbitalRingsState createState() => AnimatedOrbitalRingsState();
}

class AnimatedOrbitalRingsState extends State<AnimatedOrbitalRings>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late double _phase;
  late final ValueNotifier<double> _phaseNotifier;

  /// Continuous phase in cycles (unbounded).
  double get phase => _phase;

  @override
  void initState() {
    super.initState();
    _phase = widget.initialPhase;
    _phaseNotifier = ValueNotifier<double>(_phase);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant AnimatedOrbitalRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Speed is read each tick; no controller retarget needed.
  }

  @override
  void dispose() {
    _ticker.dispose();
    _phaseNotifier.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    final dt = delta.inMicroseconds / 1000000;
    if (dt <= 0 || dt > 0.08) {
      return;
    }

    final speed = widget.speed.clamp(
      AnimatedOrbitalRings.minSpeed,
      AnimatedOrbitalRings.maxSpeed,
    );
    final cyclesPerSecond =
        speed / AnimatedOrbitalRings.baseDuration.inSeconds;
    _phase += dt * cyclesPerSecond;
    _phaseNotifier.value = _phase;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: ValueListenableBuilder<double>(
          valueListenable: _phaseNotifier,
          builder: (context, phase, child) {
            return CustomPaint(
              painter: OrbitalRingsPainter(
                ringColor: widget.ringColor,
                phase: phase,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}
