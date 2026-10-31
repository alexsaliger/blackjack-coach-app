import 'package:coaches_dont_play/state/counting_drill_controller.dart';
import 'package:coaches_dont_play/state/settings_providers.dart';
import 'package:coaches_dont_play/state/stats_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  return c;
}

void main() {
  test('re-checking the unchanged guess does not count again', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final ctrl = c.read(countingDrillProvider.notifier);

    ctrl.dealNext();
    ctrl.checkRunningCount(0);
    final total1 = c.read(countingDrillProvider).total;
    expect(total1, 1);

    ctrl.checkRunningCount(0); // same value again -> ignored
    expect(c.read(countingDrillProvider).total, total1);

    ctrl.dealNext();
    ctrl.checkRunningCount(0); // new card -> counts again
    expect(c.read(countingDrillProvider).total, 2);
  });

  test('correcting the guess in the same round replaces, not adds', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final ctrl = c.read(countingDrillProvider.notifier);

    ctrl.dealNext();
    ctrl.checkRunningCount(99999); // almost certainly wrong
    var s = c.read(countingDrillProvider);
    final truth = s.truthRunning!;
    expect(s.total, 1);
    expect(s.correct, 0);
    expect(c.read(statsProvider).counting.correct, 0);
    expect(c.read(statsProvider).counting.total, 1);

    // Correct the guess to the revealed truth (same round).
    ctrl.checkRunningCount(truth);
    s = c.read(countingDrillProvider);
    expect(s.total, 1, reason: 'total must not grow on a correction');
    expect(s.correct, 1);
    expect(s.wasCorrect, isTrue);
    // Lifetime stats adjusted, not inflated.
    expect(c.read(statsProvider).counting.total, 1);
    expect(c.read(statsProvider).counting.correct, 1);
  });
}
