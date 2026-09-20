import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'animated_orbital_rings.dart';

class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({
    super.key,
    required this.onComplete,
    this.onCountChanged,
    this.accentColor = AppColors.coral,
  });

  final VoidCallback onComplete;

  /// Fires when each countdown step begins rendering: 3 → 2 → 1 → 0 (GO!).
  final ValueChanged<int>? onCountChanged;
  final Color accentColor;

  static const Duration dissolveDuration = Duration(milliseconds: 1400);

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  static const List<String> _steps = ['3', '2', '1', 'GO!'];
  static const double _countdownFontSize = 112;
  static final Color _ringColor = Colors.white.withValues(alpha: 0.10);

  final GlobalKey<AnimatedOrbitalRingsState> _ringsKey =
      GlobalKey<AnimatedOrbitalRingsState>();

  int _index = 0;
  bool _completed = false;

  /// Sound-friendly count: 3, 2, 1, then 0 for GO!.
  int get _countForStep => _steps.length - 1 - _index;

  void _advance() {
    if (!mounted || _completed) {
      return;
    }
    if (_index >= _steps.length - 1) {
      _finishWithDissolve();
      return;
    }
    setState(() {
      _index += 1;
    });
  }

  void _finishWithDissolve() {
    if (_completed || !mounted) {
      return;
    }
    _completed = true;

    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    final accent = widget.accentColor;
    final onComplete = widget.onComplete;

    if (overlayState == null) {
      onComplete();
      return;
    }

    // Continue ring phase so the dissolve cover does not jump to phase 0.
    final ringPhase = _ringsKey.currentState?.phase ?? 0;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CountdownDissolveCover(
        accentColor: accent,
        ringPhase: ringPhase,
        onGameReady: onComplete,
        onFinished: entry.remove,
      ),
    );
    overlayState.insert(entry);
  }

  bool get _isGo => _steps[_index] == 'GO!';

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return _CountdownFrame(
      accentColor: accent,
      ringColor: _ringColor,
      ringsKey: _ringsKey,
      stepLabel: _steps[_index],
      subtitle: _isGo ? 'Let’s play' : 'Starting soon',
      isGo: _isGo,
      stepKey: ValueKey(_index),
      stepChild: _buildStepText(context, accent),
    );
  }

  Widget _buildStepText(BuildContext context, Color accent) {
    final text = Text(
      _steps[_index],
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: _isGo ? 88 : _countdownFontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: _isGo ? 4 : -2,
            height: 1,
            shadows: [
              Shadow(
                color: accent.withValues(alpha: 0.55),
                blurRadius: 28,
              ),
              const Shadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
    );

    final entrance = text
        .animate(
          onPlay: (_) => widget.onCountChanged?.call(_countForStep),
          onComplete: (_) => _advance(),
        )
        .fadeIn(duration: 140.ms)
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );

    if (_isGo) {
      return entrance.then(delay: 420.ms);
    }

    return entrance.then(delay: 100.ms).fadeOut(duration: 200.ms);
  }
}

/// Stays in the root [Overlay] so the dissolve can finish after the tutorial
/// screen is replaced by the live game underneath.
class _CountdownDissolveCover extends StatefulWidget {
  const _CountdownDissolveCover({
    required this.accentColor,
    required this.ringPhase,
    required this.onGameReady,
    required this.onFinished,
  });

  final Color accentColor;
  final double ringPhase;
  final VoidCallback onGameReady;
  final VoidCallback onFinished;

  @override
  State<_CountdownDissolveCover> createState() =>
      _CountdownDissolveCoverState();
}

class _CountdownDissolveCoverState extends State<_CountdownDissolveCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CountdownOverlay.dissolveDuration,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _scale = Tween<double>(begin: 1, end: 1.05).animate(_fade);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) {
        return;
      }
      _started = true;
      widget.onGameReady();
      _controller.forward().whenComplete(() {
        if (mounted) {
          widget.onFinished();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 1 - _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: IgnorePointer(
        child: _CountdownFrame(
          accentColor: widget.accentColor,
          ringColor: _CountdownOverlayState._ringColor,
          ringPhase: widget.ringPhase,
          stepLabel: 'GO!',
          subtitle: 'Let’s play',
          isGo: true,
        ),
      ),
    );
  }
}

class _CountdownFrame extends StatelessWidget {
  const _CountdownFrame({
    required this.accentColor,
    required this.ringColor,
    required this.stepLabel,
    required this.subtitle,
    required this.isGo,
    this.ringsKey,
    this.ringPhase = 0,
    this.stepKey,
    this.stepChild,
  });

  final Color accentColor;
  final Color ringColor;
  final String stepLabel;
  final String subtitle;
  final bool isGo;
  final GlobalKey<AnimatedOrbitalRingsState>? ringsKey;
  final double ringPhase;
  final Key? stepKey;
  final Widget? stepChild;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.textPrimary, accentColor, 0.18)!,
            AppColors.textPrimary,
            Color.lerp(AppColors.textPrimary, accentColor, 0.28)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOrbitalRings(
            key: ringsKey,
            ringColor: ringColor,
            initialPhase: ringPhase,
          ),
          Center(
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.35),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Get ready',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                KeyedSubtree(
                  key: stepKey ?? ValueKey(stepLabel),
                  child: stepChild ??
                      Text(
                        stepLabel,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: isGo ? 88 : 112,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: isGo ? 4 : -2,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color:
                                          accentColor.withValues(alpha: 0.55),
                                      blurRadius: 28,
                                    ),
                                    const Shadow(
                                      color: Color(0x66000000),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                      ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
