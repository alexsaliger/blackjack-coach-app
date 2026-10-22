import 'card.dart';

/// A blackjack hand: an ordered list of cards plus the derived properties the
/// strategy engine needs.
class Hand {
  Hand([List<Card>? cards]) : cards = List<Card>.from(cards ?? const <Card>[]);

  final List<Card> cards;

  void add(Card card) => cards.add(card);

  /// Best total not exceeding 21 when possible: one ace counts as 11 unless
  /// that would bust, in which case it drops to 1.
  int get total {
    final (sum, _) = _evaluate();
    return sum;
  }

  /// True when an ace is still being counted as 11 in [total] (a "soft" hand).
  bool get isSoft {
    final (_, softAces) = _evaluate();
    return softAces > 0;
  }

  /// Sum and the number of aces still valued at 11 after downgrading to avoid
  /// busting.
  (int, int) _evaluate() {
    var sum = 0;
    var aces = 0;
    for (final c in cards) {
      sum += c.rank.baseValue;
      if (c.rank == Rank.ace) aces++;
    }
    while (sum > 21 && aces > 0) {
      sum -= 10;
      aces--;
    }
    return (sum, aces);
  }

  bool get isBust => total > 21;

  /// A natural: exactly two cards totalling 21.
  bool get isBlackjack => cards.length == 2 && total == 21;

  /// Two cards of equal blackjack value (so 10-K counts as a pair of tens).
  bool get isPair =>
      cards.length == 2 && cards[0].rank.baseValue == cards[1].rank.baseValue;

  /// The ten-or-rank value used for pair-splitting lookups (11 for aces),
  /// or null when the hand is not a pair.
  int? get pairValue => isPair ? cards[0].rank.baseValue : null;

  /// A fresh two-card hand (doubling and surrender are only allowed here).
  bool get isInitial => cards.length == 2;

  @override
  String toString() => cards.map((c) => c.toString()).join(' ');
}
