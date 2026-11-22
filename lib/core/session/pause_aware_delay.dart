/// Delay that does not resolve while gameplay is paused.
///
/// Waits [duration] in wall-clock time (same as [Future.delayed]), then if
/// [isPaused] is true waits until gameplay resumes before returning so
/// puzzle-advancing work cannot run mid-pause.
///
/// If [isPaused] throws (for example a disposed [WidgetRef]), the post-delay
/// gate is skipped so callers can check `mounted` and exit safely.
Future<void> pauseAwareDelay({
  required bool Function() isPaused,
  required Duration duration,
}) async {
  await Future<void>.delayed(duration);

  bool safeIsPaused() {
    try {
      return isPaused();
    } catch (_) {
      return false;
    }
  }

  while (safeIsPaused()) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
