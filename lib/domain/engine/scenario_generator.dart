import 'dart:math';

import '../models/card.dart';
import '../models/hand.dart';

/// A single basic-strategy practice situation: the player's two-card hand and
/// the dealer's upcard.
class DrillScenario {
  const DrillScenario(this.player, this.dealerUp);

  final Hand player;
  final Card dealerUp;
}

/// Generates random two-card player hands against a random dealer upcard.
/// Naturals are skipped (there is no decision to practise on a blackjack).
/// Seedable for deterministic tests.
class ScenarioGenerator {
  ScenarioGenerator({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  Card _randomCard() => Card(
        Rank.values[_rng.nextInt(Rank.values.length)],
        Suit.values[_rng.nextInt(Suit.values.length)],
      );

  DrillScenario next() {
    while (true) {
      final player = Hand([_randomCard(), _randomCard()]);
      if (player.isBlackjack) continue; // natural: nothing to decide
      return DrillScenario(player, _randomCard());
    }
  }
}
