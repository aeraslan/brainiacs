import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  static const List<String> _steps = ['3', '2', '1', 'GO!'];
  static const double _countdownFontSize = 96;

  int _index = 0;

  void _advance() {
    if (!mounted) {
      return;
    }
    if (_index >= _steps.length - 1) {
      widget.onComplete();
      return;
    }
    setState(() {
      _index += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.textPrimary.withValues(alpha: 0.78),
      child: Center(
        child:
            Text(
                  _steps[_index],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.onAccent,
                    fontSize: _countdownFontSize,
                  ),
                )
                .animate(key: ValueKey(_index), onComplete: (_) => _advance())
                .fadeIn(duration: 140.ms)
                .scale(
                  begin: const Offset(0.35, 0.35),
                  end: const Offset(1.2, 1.2),
                  duration: 320.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.7, 1.7),
                  duration: 200.ms,
                  curve: Curves.easeIn,
                )
                .fadeOut(duration: 200.ms),
      ),
    );
  }
}
