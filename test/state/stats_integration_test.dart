import 'package:coaches_dont_play/domain/models/action.dart';
import 'package:coaches_dont_play/state/basic_strategy_drill_controller.dart';
import 'package:coaches_dont_play/state/settings_providers.dart';
import 'package:coaches_dont_play/state/stats_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('answering a basic-strategy drill records into lifetime stats', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(statsProvider).basic.total, 0);

    container.read(basicStrategyDrillProvider.notifier).answer(PlayerAction.hit);

    final stats = container.read(statsProvider);
    expect(stats.basic.total, 1);
    // Persisted to prefs as well.
    expect(prefs.getString('stats'), isNotNull);
  });
}
