import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/rule_set.dart';

/// Holds the active table [RuleSet]. Every trainer and the house-edge view read
/// from here, so changing the rules in one place keeps the whole app in sync.
/// (Persistence via SharedPreferences will be wired into this notifier in a
/// later phase; for now it starts at the default rule set.)
final ruleSetProvider =
    NotifierProvider<RuleSetNotifier, RuleSet>(RuleSetNotifier.new);

class RuleSetNotifier extends Notifier<RuleSet> {
  @override
  RuleSet build() => const RuleSet();

  void set(RuleSet rules) => state = rules;

  void update(RuleSet Function(RuleSet current) change) =>
      state = change(state);
}
