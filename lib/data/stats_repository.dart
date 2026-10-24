import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/stats.dart';

/// Persists lifetime drill statistics in local storage via SharedPreferences.
class StatsRepository {
  StatsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'stats';

  StatsData load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const StatsData();
    try {
      return StatsData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const StatsData();
    }
  }

  Future<void> save(StatsData stats) =>
      _prefs.setString(_key, jsonEncode(stats.toJson()));
}
