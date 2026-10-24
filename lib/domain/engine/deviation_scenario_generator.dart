import 'dart:math';

import '../models/card.dart';
import '../models/hand.dart';
import '../strategy/deviations.dart';

/// A deviation practice situation: a hand/upcard that matches one of the index
/// plays, plus a true count near that play's index so the deviation actually
/// matters. [deviation] is the matched entry, used for feedback.
class DeviationDrillScenario {
  const DeviationDrillScenario(
    this.player,
    this.dealerUp,
    this.trueCount,
    this.deviation,
  );

  final Hand player;
  final Card dealerUp;
  final double trueCount;
  final Deviation deviation;
}

/// Builds deviation scenarios by picking a random index play, constructing a
/// matching hand, and choosing a true count within ±3 of its index. Seedable
/// for deterministic tests.
class DeviationScenarioGenerator {
  DeviationScenarioGenerator({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  static const _deviations = Deviations();

  DeviationDrillScenario next() {
    final picked = Deviations.all[_rng.nextInt(Deviations.all.length)];
    final player = picked.isPair ? _pairHand(picked.key) : _hardHand(picked.key);
    final up = _cardForValue(picked.dealerUp);
    // The deviation `recommend()` will actually resolve to (some signatures,
    // e.g. 15 v 10, appear in both lists; lookup returns the first). Carry that
    // one so feedback and grading always agree, and centre the count on it.
    final actual = _deviations.lookup(player, up) ?? picked;
    final trueCount = (actual.index + (_rng.nextInt(7) - 3)).toDouble();
    return DeviationDrillScenario(player, up, trueCount, actual);
  }

  /// A face-up card worth [value] (11 = Ace, 10 = any ten-valued card).
  Card _cardForValue(int value) {
    final suit = Suit.values[_rng.nextInt(Suit.values.length)];
    if (value == 11) return Card(Rank.ace, suit);
    if (value == 10) {
      const tens = [Rank.ten, Rank.jack, Rank.queen, Rank.king];
      return Card(tens[_rng.nextInt(tens.length)], suit);
    }
    final rank =
        Rank.values.firstWhere((r) => r != Rank.ace && r.baseValue == value);
    return Card(rank, suit);
  }

  /// A two-card hard hand totalling [total] (no ace, not a pair).
  Hand _hardHand(int total) {
    final candidates = [2, 3, 4, 5, 6, 7, 8, 9, 10]..shuffle(_rng);
    for (final c1 in candidates) {
      final c2 = total - c1;
      if (c2 >= 2 && c2 <= 10 && c2 != c1) {
        return Hand([_cardForValue(c1), _cardForValue(c2)]);
      }
    }
    // Fallback (not reached for the tabulated deviation keys).
    return Hand([_cardForValue(10), _cardForValue(total - 10)]);
  }

  /// A two-card pair worth [value] each (10 uses a ten + a face card).
  Hand _pairHand(int value) {
    if (value == 10) {
      return Hand([
        const Card(Rank.ten, Suit.spades),
        const Card(Rank.king, Suit.hearts),
      ]);
    }
    final rank = Rank.values.firstWhere((r) => r.baseValue == value);
    return Hand([Card(rank, Suit.spades), Card(rank, Suit.hearts)]);
  }
}
