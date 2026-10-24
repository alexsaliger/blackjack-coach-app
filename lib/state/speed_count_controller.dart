import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/counting/hilo_counter.dart';
import '../domain/engine/shoe.dart';
import '../domain/models/card.dart';

enum SpeedPhase { idle, running, entering, finished }

class SpeedCountState {
  const SpeedCountState({
    this.phase = SpeedPhase.idle,
    this.decks = 1,
    this.current,
    this.dealt = 0,
    this.total = 0,
    this.elapsedMs = 0,
    this.guess,
    this.truthRunning,
    this.wasCorrect,
  });

  final SpeedPhase phase;
  final int decks;
  final Card? current;
  final int dealt;
  final int total;
  final int elapsedMs;

  // Populated once the player submits a final running-count guess.
  final int? guess;
  final int? truthRunning;
  final bool? wasCorrect;

  double get cardsPerSecond =>
      elapsedMs == 0 ? 0 : dealt / (elapsedMs / 1000);

  SpeedCountState copyWith({
    SpeedPhase? phase,
    int? decks,
    Card? current,
    int? dealt,
    int? total,
    int? elapsedMs,
    int? guess,
    int? truthRunning,
    bool? wasCorrect,
  }) {
    return SpeedCountState(
      phase: phase ?? this.phase,
      decks: decks ?? this.decks,
      current: current ?? this.current,
      dealt: dealt ?? this.dealt,
      total: total ?? this.total,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      guess: guess ?? this.guess,
      truthRunning: truthRunning ?? this.truthRunning,
      wasCorrect: wasCorrect ?? this.wasCorrect,
    );
  }
}

final speedCountProvider =
    NotifierProvider<SpeedCountController, SpeedCountState>(
  SpeedCountController.new,
);

/// Drives the speed-count drill: deals an entire shoe one tap at a time while a
/// stopwatch runs, then checks the player's final running count and reports the
/// time and speed.
class SpeedCountController extends Notifier<SpeedCountState> {
  Shoe? _shoe;
  final HiLoCounter _counter = HiLoCounter();
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;

  @override
  SpeedCountState build() {
    ref.onDispose(_stopTicker);
    return const SpeedCountState();
  }

  void chooseDecks(int decks) {
    if (state.phase != SpeedPhase.idle) return;
    state = state.copyWith(decks: decks);
  }

  void start() {
    _shoe = Shoe(deckCount: state.decks, penetration: 1.0);
    _counter.reset();
    _watch
      ..reset()
      ..start();
    _startTicker();

    final first = _shoe!.deal();
    _counter.record(first);
    state = SpeedCountState(
      phase: SpeedPhase.running,
      decks: state.decks,
      current: first,
      dealt: 1,
      total: _shoe!.totalCards,
      elapsedMs: 0,
    );
  }

  /// Reveals the next card. When the shoe is empty, moves to the entry phase.
  void nextCard() {
    if (state.phase != SpeedPhase.running) return;
    final card = _shoe!.deal();
    _counter.record(card);
    final dealt = state.dealt + 1;
    state = state.copyWith(current: card, dealt: dealt);
    if (_shoe!.cardsRemaining == 0) _finishDealing();
  }

  void _finishDealing() {
    _watch.stop();
    _stopTicker();
    state = state.copyWith(
      phase: SpeedPhase.entering,
      elapsedMs: _watch.elapsedMilliseconds,
    );
  }

  void submit(int guess) {
    if (state.phase != SpeedPhase.entering) return;
    final truth = _counter.runningCount;
    state = state.copyWith(
      phase: SpeedPhase.finished,
      guess: guess,
      truthRunning: truth,
      wasCorrect: guess == truth,
    );
  }

  void reset() {
    _stopTicker();
    _watch.stop();
    state = SpeedCountState(decks: state.decks);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_watch.isRunning) {
        state = state.copyWith(elapsedMs: _watch.elapsedMilliseconds);
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
