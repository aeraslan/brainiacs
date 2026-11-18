import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rank/title_progress_notifier.dart';
import '../domain/player_statistics.dart';
import 'session_history_notifier.dart';

final playerStatisticsProvider = Provider<PlayerStatistics>((ref) {
  final progress = ref.watch(titleProgressProvider);
  final history = ref.watch(sessionHistoryProvider);
  return PlayerStatistics.compute(progress: progress, history: history);
});
