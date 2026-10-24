import 'dart:math';

/// Lifetime accuracy counters for one drill category.
class CategoryStats {
  const CategoryStats({this.correct = 0, this.total = 0, this.bestStreak = 0});

  final int correct;
  final int total;
  final int bestStreak;

  double get accuracy => total == 0 ? 0 : correct / total;

  /// Returns a copy with one more attempt recorded. [streak] is the current
  /// session streak, used to keep the all-time best.
  CategoryStats record(bool ok, int streak) => CategoryStats(
        correct: correct + (ok ? 1 : 0),
        total: total + 1,
        bestStreak: max(bestStreak, streak),
      );

  Map<String, dynamic> toJson() =>
      {'correct': correct, 'total': total, 'bestStreak': bestStreak};

  factory CategoryStats.fromJson(Map<String, dynamic> j) => CategoryStats(
        correct: j['correct'] as int? ?? 0,
        total: j['total'] as int? ?? 0,
        bestStreak: j['bestStreak'] as int? ?? 0,
      );
}

/// All persisted lifetime statistics across the trainers.
class StatsData {
  const StatsData({
    this.basic = const CategoryStats(),
    this.counting = const CategoryStats(),
    this.deviations = const CategoryStats(),
    this.speedBestTimeMs = 0,
    this.speedRuns = 0,
  });

  final CategoryStats basic;
  final CategoryStats counting;
  final CategoryStats deviations;

  /// Best (lowest) full-shoe time in ms; 0 means no run yet.
  final int speedBestTimeMs;
  final int speedRuns;

  StatsData copyWith({
    CategoryStats? basic,
    CategoryStats? counting,
    CategoryStats? deviations,
    int? speedBestTimeMs,
    int? speedRuns,
  }) =>
      StatsData(
        basic: basic ?? this.basic,
        counting: counting ?? this.counting,
        deviations: deviations ?? this.deviations,
        speedBestTimeMs: speedBestTimeMs ?? this.speedBestTimeMs,
        speedRuns: speedRuns ?? this.speedRuns,
      );

  Map<String, dynamic> toJson() => {
        'basic': basic.toJson(),
        'counting': counting.toJson(),
        'deviations': deviations.toJson(),
        'speedBestTimeMs': speedBestTimeMs,
        'speedRuns': speedRuns,
      };

  factory StatsData.fromJson(Map<String, dynamic> j) => StatsData(
        basic: _cat(j['basic']),
        counting: _cat(j['counting']),
        deviations: _cat(j['deviations']),
        speedBestTimeMs: j['speedBestTimeMs'] as int? ?? 0,
        speedRuns: j['speedRuns'] as int? ?? 0,
      );

  static CategoryStats _cat(Object? v) => v is Map<String, dynamic>
      ? CategoryStats.fromJson(v)
      : const CategoryStats();
}
