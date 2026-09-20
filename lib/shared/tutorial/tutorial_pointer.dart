import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

class TutorialPointerController {
  TutorialPointerController({required this.overlayKey});

  final GlobalKey overlayKey;
  final ValueNotifier<Offset> position = ValueNotifier(
    const Offset(-160, -160),
  );
  final ValueNotifier<bool> isPressing = ValueNotifier(false);

  static const Duration moveDuration = Duration(milliseconds: 420);
  static const Duration pressDuration = Duration(milliseconds: 140);

  Offset? centerOf(GlobalKey key) {
    final target = key.currentContext?.findRenderObject();
    final overlay = overlayKey.currentContext?.findRenderObject();
    if (target is! RenderBox || overlay is! RenderBox || !target.hasSize) {
      return null;
    }

    final global = target.localToGlobal(target.size.center(Offset.zero));
    return overlay.globalToLocal(global);
  }

  Future<bool> tapKey(GlobalKey key) async {
    final moved = await moveToKey(key);
    if (!moved) {
      return false;
    }

    isPressing.value = true;
    await Future<void>.delayed(pressDuration);
    isPressing.value = false;
    return true;
  }

  /// Moves the pointer to [key] without pressing (e.g. rest spot off the board).
  Future<bool> moveToKey(GlobalKey key) async {
    final target = centerOf(key);
    if (target == null) {
      return false;
    }

    position.value = target;
    await Future<void>.delayed(moveDuration);
    final settled = centerOf(key);
    if (settled != null) {
      position.value = settled;
    }
    return true;
  }

  void hide() {
    isPressing.value = false;
    position.value = const Offset(-160, -160);
  }

  void dispose() {
    position.dispose();
    isPressing.dispose();
  }
}

class TutorialPointer extends StatelessWidget {
  const TutorialPointer({super.key, required this.controller});

  final TutorialPointerController controller;

  static const double _iconSize = 48;
  static const Offset _hotspot = Offset(10, 8);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: controller.position,
      builder: (context, offset, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isPressing,
          builder: (context, isPressing, _) {
            return Positioned(
              left: offset.dx - _hotspot.dx,
              top: offset.dy - _hotspot.dy,
              child: IgnorePointer(
                child:
                    Icon(
                          Icons.touch_app,
                          size: _iconSize,
                          color: AppColors.textPrimary,
                        )
                        .animate(target: isPressing ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(0.82, 0.82),
                          duration: 120.ms,
                        ),
              ),
            );
          },
        );
      },
    );
  }
}

Future<bool> waitUntil(
  bool Function() test, {
  required bool Function() isActive,
  Duration timeout = const Duration(seconds: 4),
  Duration interval = const Duration(milliseconds: 50),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (isActive()) {
    if (test()) {
      return true;
    }
    if (DateTime.now().isAfter(deadline)) {
      return false;
    }
    await Future<void>.delayed(interval);
  }
  return false;
}

String wrongDigitString(int correctAnswer, int digitCount) {
  final modulus = _pow10(digitCount);
  var wrong = (correctAnswer + 1) % modulus;
  if (wrong == correctAnswer) {
    wrong = (correctAnswer + 2) % modulus;
  }
  return wrong.toString().padLeft(digitCount, '0');
}

int _pow10(int exponent) {
  var value = 1;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}
