import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/rule_set.dart';

/// Persists user settings (currently the table [RuleSet]) in local storage via
/// SharedPreferences. This is the single place that knows how settings are
/// stored, so swapping the backend later touches only this class.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _ruleSetKey = 'ruleSet';

  RuleSet loadRuleSet() {
    final raw = _prefs.getString(_ruleSetKey);
    if (raw == null) return const RuleSet();
    try {
      return RuleSet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const RuleSet();
    }
  }

  Future<void> saveRuleSet(RuleSet rules) =>
      _prefs.setString(_ruleSetKey, jsonEncode(rules.toJson()));
}
