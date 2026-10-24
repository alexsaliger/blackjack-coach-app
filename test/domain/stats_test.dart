import 'package:coaches_dont_play/domain/models/stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryStats', () {
    test('record accumulates and tracks best streak', () {
      var s = const CategoryStats();
      s = s.record(true, 1);
      s = s.record(false, 0);
      s = s.record(true, 1);
      s = s.record(true, 2);
      expect(s.correct, 3);
      expect(s.total, 4);
      expect(s.bestStreak, 2);
      expect(s.accuracy, closeTo(0.75, 1e-9));
    });
  });

  group('StatsData JSON', () {
    test('round-trips', () {
      const data = StatsData(
        basic: CategoryStats(correct: 5, total: 8, bestStreak: 4),
        counting: CategoryStats(correct: 2, total: 3),
        deviations: CategoryStats(correct: 1, total: 1, bestStreak: 1),
        speedBestTimeMs: 42000,
        speedRuns: 3,
      );
      final restored = StatsData.fromJson(data.toJson());
      expect(restored.basic.correct, 5);
      expect(restored.basic.bestStreak, 4);
      expect(restored.counting.total, 3);
      expect(restored.speedBestTimeMs, 42000);
      expect(restored.speedRuns, 3);
    });

    test('tolerates empty/missing json', () {
      final d = StatsData.fromJson({});
      expect(d.basic.total, 0);
      expect(d.speedRuns, 0);
    });
  });
}
