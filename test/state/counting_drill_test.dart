import 'package:coaches_dont_play/state/counting_drill_controller.dart';
import 'package:coaches_dont_play/state/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('a repeated check without a new card is not counted again', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);

    final ctrl = c.read(countingDrillProvider.notifier);

    ctrl.dealNext();
    ctrl.checkRunningCount(0);
    final total1 = c.read(countingDrillProvider).total;
    expect(total1, 1);

    // Tapping "Pruefen" again without dealing is ignored.
    ctrl.checkRunningCount(0);
    expect(c.read(countingDrillProvider).total, total1);

    // After dealing a new card, a check counts again.
    ctrl.dealNext();
    ctrl.checkRunningCount(0);
    expect(c.read(countingDrillProvider).total, 2);
  });
}
