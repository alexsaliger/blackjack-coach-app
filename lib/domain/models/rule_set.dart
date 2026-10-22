/// How a natural blackjack pays out.
enum BlackjackPayout {
  threeToTwo(1.5, '3:2'),
  sixToFive(1.2, '6:5');

  const BlackjackPayout(this.multiplier, this.label);
  final double multiplier;
  final String label;
}

/// The configurable table rules. One [RuleSet] drives the strategy engine,
/// the true-count conversion (via penetration/decks) and the house-edge
/// calculator, so every trainer stays consistent with the player's setup.
class RuleSet {
  const RuleSet({
    this.decks = 6,
    this.dealerHitsSoft17 = false,
    this.doubleAfterSplit = true,
    this.surrenderAllowed = true,
    this.resplitAces = false,
    this.maxSplitHands = 4,
    this.blackjackPayout = BlackjackPayout.threeToTwo,
    this.penetration = 0.75,
  });

  /// Number of 52-card decks in the shoe (1, 2, 4, 6 or 8 typically).
  final int decks;

  /// false → dealer stands on soft 17 (S17); true → dealer hits (H17).
  final bool dealerHitsSoft17;

  /// Doubling allowed after a split (DAS).
  final bool doubleAfterSplit;

  /// Late surrender offered.
  final bool surrenderAllowed;

  /// Aces may be re-split.
  final bool resplitAces;

  /// Maximum number of hands a player may split to.
  final int maxSplitHands;

  final BlackjackPayout blackjackPayout;

  /// Fraction of the shoe dealt before the cut card forces a reshuffle
  /// (0.0–1.0). Affects how deep the count can run.
  final double penetration;

  RuleSet copyWith({
    int? decks,
    bool? dealerHitsSoft17,
    bool? doubleAfterSplit,
    bool? surrenderAllowed,
    bool? resplitAces,
    int? maxSplitHands,
    BlackjackPayout? blackjackPayout,
    double? penetration,
  }) {
    return RuleSet(
      decks: decks ?? this.decks,
      dealerHitsSoft17: dealerHitsSoft17 ?? this.dealerHitsSoft17,
      doubleAfterSplit: doubleAfterSplit ?? this.doubleAfterSplit,
      surrenderAllowed: surrenderAllowed ?? this.surrenderAllowed,
      resplitAces: resplitAces ?? this.resplitAces,
      maxSplitHands: maxSplitHands ?? this.maxSplitHands,
      blackjackPayout: blackjackPayout ?? this.blackjackPayout,
      penetration: penetration ?? this.penetration,
    );
  }

  /// A common 6-deck Las Vegas Strip rule set (S17, DAS, late surrender).
  static const vegas6Deck = RuleSet();
}
