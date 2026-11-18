import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Registers a gameplay answer on pointer-down instead of waiting for tap-up.
///
/// Uses [Listener] so the gesture arena never cancels a press that slides
/// outside the hit target. One physical touch produces at most one callback
/// per widget instance; a second finger on a sibling widget can still fire.
class PressDownDetector extends StatefulWidget {
  const PressDownDetector({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
    this.onPressedChanged,
    this.semanticLabel,
  });

  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;
  final HitTestBehavior behavior;

  /// Optional pressed-visual callback (true on down, false on up/cancel).
  final ValueChanged<bool>? onPressedChanged;

  final String? semanticLabel;

  @override
  State<PressDownDetector> createState() => _PressDownDetectorState();
}

class _PressDownDetectorState extends State<PressDownDetector> {
  int? _activePointer;

  bool get _isTracking => _activePointer != null;

  void _setPressed(bool value) {
    widget.onPressedChanged?.call(value);
  }

  void _clearPointer() {
    if (_activePointer == null) {
      return;
    }
    _activePointer = null;
    _setPressed(false);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) {
      return;
    }
    if (_activePointer != null) {
      return;
    }
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryButton) {
      return;
    }

    _activePointer = event.pointer;
    _setPressed(true);
    widget.onPressed();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _clearPointer();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _clearPointer();
  }

  @override
  void didUpdateWidget(PressDownDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _isTracking) {
      _clearPointer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: Listener(
        behavior: widget.behavior,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: widget.child,
      ),
    );
  }
}
