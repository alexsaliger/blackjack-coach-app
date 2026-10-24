import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/engine/deviation_scenario_generator.dart';
import '../domain/models/action.dart';
import '../domain/strategy/basic_strategy.dart';
import '../domain/strategy/deviations.dart';
import 'settings_providers.dart';
import 'stats_providers.dart';

class DeviationDrillState {
  const DeviationDrillState({
    required this.scenario,
    this.chosen,
    this.correctAction,
    this.revealed = false,
    this.wasCorrect,
    this.correct = 0,
    this.total = 0,
    this.streak = 0,
    this.bestStreak = 0,
  });

  final DeviationDrillScenario scenario;
  final PlayerAction? chosen;
  final PlayerAction? correctAction;
  final bool revealed;
  final bool? wasCorrect;

  final int correct;
  final int total;
  final int streak;
  final int bestStreak;

  double get accuracy => total == 0 ? 0 : correct / total;

  DeviationDrillState copyWith({
    DeviationDrillScenario? scenario,
    PlayerAction? chosen,
    PlayerAction? correctAction,
    bool? revealed,
    bool? wasCorrect,
    int? correct,
    int? total,
    int? streak,
    int? bestStreak,
  }) {
    return DeviationDrillState(
      scenario: scenario ?? this.scenario,
      chosen: chosen ?? this.chosen,
      correctAction: correctAction ?? this.correctAction,
      revealed: revealed ?? this.revealed,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      correct: correct ?? this.correct,
      total: total ?? this.total,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}

final deviationDrillProvider =
    NotifierProvider<DeviationDrillController, DeviationDrillState>(
  DeviationDrillController.new,
);

/// Drives the deviation drill: shows a hand/upcard plus a true count and grades
/// the player's choice against the count-adjusted [Deviations] recommendation.
class DeviationDrillController extends Notifier<DeviationDrillState> {
  final DeviationScenarioGenerator _gen = DeviationScenarioGenerator();
  final Deviations _deviations = const Deviations();

  @override
  DeviationDrillState build() =>
      DeviationDrillState(scenario: _gen.next());

  void answer(PlayerAction guess) {
    if (state.revealed) return;
    final rules = ref.read(ruleSetProvider);
    final s = state.scenario;
    final basic = BasicStrategy(rules).recommend(s.player, s.dealerUp);
    final correctAction =
        _deviations.recommend(s.player, s.dealerUp, s.trueCount, basic);
    final ok = guess == correctAction;
    final newStreak = ok ? state.streak + 1 : 0;

    state = state.copyWith(
      chosen: guess,
      correctAction: correctAction,
      revealed: true,
      wasCorrect: ok,
      correct: state.correct + (ok ? 1 : 0),
      total: state.total + 1,
      streak: newStreak,
      bestStreak: max(state.bestStreak, newStreak),
    );
    ref.read(statsProvider.notifier).recordDeviation(ok, newStreak);
  }

  void next() {
    state = DeviationDrillState(
      scenario: _gen.next(),
      correct: state.correct,
      total: state.total,
      streak: state.streak,
      bestStreak: state.bestStreak,
    );
  }
}
