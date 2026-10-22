/// A playing-card rank with its blackjack and Hi-Lo properties.
enum Rank {
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(10),
  queen(10),
  king(10),
  ace(11);

  const Rank(this.baseValue);

  /// Blackjack point value. Aces are 11 here; [Hand] downgrades an ace to 1
  /// when counting it as 11 would bust.
  final int baseValue;

  /// Hi-Lo running-count contribution: 2–6 → +1, 7–9 → 0, 10/face/Ace → −1.
  int get hiLoValue {
    switch (this) {
      case Rank.two:
      case Rank.three:
      case Rank.four:
      case Rank.five:
      case Rank.six:
        return 1;
      case Rank.seven:
      case Rank.eight:
      case Rank.nine:
        return 0;
      default:
        return -1;
    }
  }

  /// Short display label, e.g. "A", "10", "K".
  String get label {
    switch (this) {
      case Rank.ace:
        return 'A';
      case Rank.king:
        return 'K';
      case Rank.queen:
        return 'Q';
      case Rank.jack:
        return 'J';
      default:
        return baseValue.toString();
    }
  }
}

/// The four card suits. Suit is cosmetic in blackjack but needed to build a
/// realistic shoe.
enum Suit {
  hearts('♥'),
  diamonds('♦'),
  clubs('♣'),
  spades('♠');

  const Suit(this.symbol);
  final String symbol;
}

/// A single playing card: a [Rank] and a [Suit].
class Card {
  const Card(this.rank, this.suit);

  final Rank rank;
  final Suit suit;

  /// Hi-Lo count contribution of this card.
  int get hiLoValue => rank.hiLoValue;

  /// True for any ten-valued card (10, J, Q, K).
  bool get isTen => rank.baseValue == 10;

  @override
  String toString() => '${rank.label}${suit.symbol}';

  @override
  bool operator ==(Object other) =>
      other is Card && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => Object.hash(rank, suit);
}
