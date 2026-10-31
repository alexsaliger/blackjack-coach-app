import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/counting/hilo_counter.dart';
import '../domain/engine/shoe.dart';
import '../domain/models/card.dart';
import 'settings_providers.dart';
import 'stats_providers.dart';

/// Immutable state of the card-counting drill.
class CountingDrillState {
  const CountingDrillState({
    this.dealt = const [],
    required this.decksRemaining,
    this.cardsRemaining = 0,
    this.needsReshuffle = false,
    this.guess,
    this.revealed = false,
    this.wasCorrect,
    this.truthRunning,
    this.truthTrue,
    this.correct = 0,
    this.total = 0,
  });

  /// Cards revealed so far in the current shoe.
  final List<Card> dealt;
  final double decksRemaining;
  final int cardsRemaining;
  final bool needsReshuffle;

  /// The player's last running-count guess and whether it was right. These are
  /// only populated after a check; the truth stays hidden until then.
  final int? guess;
  final bool revealed;
  final bool? wasCorrect;
  final int? truthRunning;
  final double? truthTrue;

  final int correct;
  final int total;

  CountingDrillState copyWith({
    List<Card>? dealt,
    double? decksRemaining,
    int? cardsRemaining,
    bool? needsReshuffle,
    int? guess,
    bool? revealed,
    bool? wasCorrect,
    int? truthRunning,
    double? truthTrue,
    int? correct,
    int? total,
  }) {
    return CountingDrillState(
      dealt: dealt ?? this.dealt,
      decksRemaining: decksRemaining ?? this.decksRemaining,
      cardsRemaining: cardsRemaining ?? this.cardsRemaining,
      needsReshuffle: needsReshuffle ?? this.needsReshuffle,
      guess: guess,
      revealed: revealed ?? this.revealed,
      wasCorrect: wasCorrect,
      truthRunning: truthRunning,
      truthTrue: truthTrue,
      correct: correct ?? this.correct,
      total: total ?? this.total,
    );
  }
}

final countingDrillProvider =
    NotifierProvider<CountingDrillController, CountingDrillState>(
  CountingDrillController.new,
);

/// Drives the counting drill: deals from a shoe while hiding the running count,
/// and grades the player's running-count guesses against a [HiLoCounter].
class CountingDrillController extends Notifier<CountingDrillState> {
  late Shoe _shoe;
  final HiLoCounter _counter = HiLoCounter();

  @override
  CountingDrillState build() {
    _startShoe();
    return CountingDrillState(
      decksRemaining: _shoe.decksRemaining,
      cardsRemaining: _shoe.cardsRemaining,
    );
  }

  void _startShoe() {
    final rules = ref.read(ruleSetProvider);
    _shoe = Shoe(deckCount: rules.decks, penetration: rules.penetration);
    _counter.reset();
  }

  /// Reveals the next card and updates the hidden running count.
  void dealNext() {
    if (_shoe.needsReshuffle || _shoe.cardsRemaining == 0) return;
    final card = _shoe.deal();
    _counter.record(card);
    state = CountingDrillState(
      dealt: [...state.dealt, card],
      decksRemaining: _shoe.decksRemaining,
      cardsRemaining: _shoe.cardsRemaining,
      needsReshuffle: _shoe.needsReshuffle,
      correct: state.correct,
      total: state.total,
    );
  }

  /// Grades a running-count [guess] against the true running count.
  void checkRunningCount(int guess) {
    final truth = _counter.runningCount;
    final ok = guess == truth;
    final trueCount = _counter.trueCount(_shoe.decksRemaining);

    if (state.revealed) {
      // Already checked this round. Allow correcting the guess (which replaces
      // the result) but ignore re-taps with the unchanged value, so the
      // accuracy can't be inflated by tapping "Prüfen" repeatedly.
      if (guess == state.guess) return;
      final prevOk = state.wasCorrect ?? false;
      state = state.copyWith(
        guess: guess,
        wasCorrect: ok,
        truthRunning: truth,
        truthTrue: trueCount,
        correct: state.correct - (prevOk ? 1 : 0) + (ok ? 1 : 0),
      );
      ref.read(statsProvider.notifier).amendCounting(prevOk, ok);
      return;
    }

    // First check of the round: counts once.
    state = state.copyWith(
      guess: guess,
      revealed: true,
      wasCorrect: ok,
      truthRunning: truth,
      truthTrue: trueCount,
      correct: state.correct + (ok ? 1 : 0),
      total: state.total + 1,
    );
    ref.read(statsProvider.notifier).recordCounting(ok);
  }

  /// Fresh shoe; keeps the running accuracy tally.
  void resetShoe() {
    _startShoe();
    state = CountingDrillState(
      decksRemaining: _shoe.decksRemaining,
      cardsRemaining: _shoe.cardsRemaining,
      correct: state.correct,
      total: state.total,
    );
  }
}
