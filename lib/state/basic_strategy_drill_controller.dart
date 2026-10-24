import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/engine/scenario_generator.dart';
import '../domain/models/action.dart';
import '../domain/strategy/basic_strategy.dart';
import 'settings_providers.dart';
import 'stats_providers.dart';

/// Immutable state of the basic-strategy drill.
class BasicStrategyDrillState {
  const BasicStrategyDrillState({
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

  final DrillScenario scenario;
  final PlayerAction? chosen;
  final PlayerAction? correctAction;
  final bool revealed;
  final bool? wasCorrect;

  final int correct;
  final int total;
  final int streak;
  final int bestStreak;

  double get accuracy => total == 0 ? 0 : correct / total;

  BasicStrategyDrillState copyWith({
    DrillScenario? scenario,
    PlayerAction? chosen,
    PlayerAction? correctAction,
    bool? revealed,
    bool? wasCorrect,
    int? correct,
    int? total,
    int? streak,
    int? bestStreak,
  }) {
    return BasicStrategyDrillState(
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

final basicStrategyDrillProvider =
    NotifierProvider<BasicStrategyDrillController, BasicStrategyDrillState>(
  BasicStrategyDrillController.new,
);

/// Drives the basic-strategy drill: presents a scenario, grades the player's
/// choice against [BasicStrategy], and tracks accuracy and streaks.
class BasicStrategyDrillController extends Notifier<BasicStrategyDrillState> {
  final ScenarioGenerator _gen = ScenarioGenerator();

  @override
  BasicStrategyDrillState build() =>
      BasicStrategyDrillState(scenario: _gen.next());

  void answer(PlayerAction guess) {
    if (state.revealed) return;
    final rules = ref.read(ruleSetProvider);
    final correctAction =
        BasicStrategy(rules).recommend(state.scenario.player, state.scenario.dealerUp);
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
    ref.read(statsProvider.notifier).recordBasic(ok, newStreak);
  }

  void next() {
    state = BasicStrategyDrillState(
      scenario: _gen.next(),
      correct: state.correct,
      total: state.total,
      streak: state.streak,
      bestStreak: state.bestStreak,
    );
  }

  void resetStats() {
    state = BasicStrategyDrillState(scenario: _gen.next());
  }
}
