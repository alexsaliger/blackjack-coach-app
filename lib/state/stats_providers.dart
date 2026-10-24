import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stats_repository.dart';
import '../domain/models/stats.dart';
import 'settings_providers.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(sharedPreferencesProvider)),
);

/// Holds lifetime statistics across all trainers, loaded on start and persisted
/// after every recorded attempt.
final statsProvider = NotifierProvider<StatsNotifier, StatsData>(
  StatsNotifier.new,
);

class StatsNotifier extends Notifier<StatsData> {
  StatsRepository get _repo => ref.read(statsRepositoryProvider);

  @override
  StatsData build() => _repo.load();

  void _set(StatsData next) {
    state = next;
    _repo.save(next);
  }

  void recordBasic(bool ok, int streak) =>
      _set(state.copyWith(basic: state.basic.record(ok, streak)));

  void recordDeviation(bool ok, int streak) =>
      _set(state.copyWith(deviations: state.deviations.record(ok, streak)));

  void recordCounting(bool ok) =>
      _set(state.copyWith(counting: state.counting.record(ok, 0)));

  /// Records a completed speed-count run and keeps the best time.
  void recordSpeed(int timeMs) {
    final best = state.speedBestTimeMs == 0
        ? timeMs
        : min(state.speedBestTimeMs, timeMs);
    _set(state.copyWith(speedBestTimeMs: best, speedRuns: state.speedRuns + 1));
  }

  void resetAll() => _set(const StatsData());
}
