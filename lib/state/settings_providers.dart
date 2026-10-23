import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../domain/models/rule_set.dart';

/// Overridden in `main()` with the loaded SharedPreferences instance so the rest
/// of the app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

/// Holds the active table [RuleSet]. Loads the persisted value on start and
/// writes every change back. Every trainer and the house-edge view read from
/// here, so changing the rules in one place keeps the whole app in sync.
final ruleSetProvider =
    NotifierProvider<RuleSetNotifier, RuleSet>(RuleSetNotifier.new);

class RuleSetNotifier extends Notifier<RuleSet> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  RuleSet build() => _repo.loadRuleSet();

  void set(RuleSet rules) {
    state = rules;
    _repo.saveRuleSet(rules);
  }

  void update(RuleSet Function(RuleSet current) change) => set(change(state));
}
