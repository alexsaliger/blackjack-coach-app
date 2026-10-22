import '../models/rule_set.dart';

/// One named contribution to the house edge, in percent of the initial bet.
/// Positive helps the house; negative helps the player.
class EdgeComponent {
  const EdgeComponent(this.label, this.percent);
  final String label;
  final double percent;
}

/// A breakdown of the house edge for a rule set.
class HouseEdgeResult {
  const HouseEdgeResult(this.components);

  final List<EdgeComponent> components;

  /// Total house edge in percent (player disadvantage when positive).
  double get totalPercent =>
      components.fold(0.0, (sum, c) => sum + c.percent);
}

/// Estimates the house edge for a [RuleSet] assuming perfect basic strategy.
///
/// Uses the standard published rule-effect values (in % of the initial bet).
/// The baseline represents: 6 decks, dealer stands on soft 17, double on any
/// two cards, no DAS, no surrender, no resplit aces, blackjack pays 3:2.
/// Individual rules then add or subtract their well-known effect. These are
/// the commonly cited approximations (e.g. Wizard of Odds), accurate to a few
/// hundredths of a percent — appropriate for a house-edge calculator.
class HouseEdgeCalculator {
  const HouseEdgeCalculator();

  /// Baseline edge for the reference rule set described above.
  static const double _baseEdge = 0.54;

  /// Deck-count effect relative to the 6-deck baseline.
  static const Map<int, double> _deckEffect = {
    1: -0.59,
    2: -0.35,
    4: -0.13,
    6: 0.0,
    8: 0.02,
  };

  HouseEdgeResult compute(RuleSet rules) {
    final components = <EdgeComponent>[
      const EdgeComponent('Basis (6 Decks, S17, 3:2)', _baseEdge),
    ];

    final deck = _deckEffect[rules.decks];
    if (deck != null && deck != 0.0) {
      components.add(EdgeComponent('${rules.decks} Decks', deck));
    }

    if (rules.dealerHitsSoft17) {
      components.add(const EdgeComponent('Dealer hits soft 17 (H17)', 0.22));
    }
    if (rules.blackjackPayout == BlackjackPayout.sixToFive) {
      components.add(const EdgeComponent('Blackjack zahlt 6:5', 1.39));
    }
    if (rules.doubleAfterSplit) {
      components.add(const EdgeComponent('Double after split (DAS)', -0.14));
    }
    if (rules.surrenderAllowed) {
      components.add(const EdgeComponent('Late surrender', -0.08));
    }
    if (rules.resplitAces) {
      components.add(const EdgeComponent('Resplit aces', -0.07));
    }

    return HouseEdgeResult(components);
  }

  /// Convenience: just the total house edge in percent.
  double edgePercent(RuleSet rules) => compute(rules).totalPercent;
}
