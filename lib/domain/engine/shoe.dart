import 'dart:math';

import '../models/card.dart';

/// A multi-deck shoe with a seedable shuffle. Passing a seeded [Random] makes
/// deal order deterministic, which keeps the engine fully unit-testable.
class Shoe {
  Shoe({required this.deckCount, this.penetration = 0.75, Random? random})
      : _random = random ?? Random() {
    reshuffle();
  }

  final int deckCount;
  final double penetration;
  final Random _random;

  final List<Card> _cards = <Card>[];
  int _position = 0;

  int get totalCards => deckCount * 52;
  int get cardsDealt => _position;
  int get cardsRemaining => _cards.length - _position;

  /// Decks still in the shoe, as a fraction (used for the true-count divisor).
  double get decksRemaining => cardsRemaining / 52.0;

  /// True once the dealt fraction has reached [penetration]; the next round
  /// should start from a fresh shuffle.
  bool get needsReshuffle => cardsDealt >= totalCards * penetration;

  /// Rebuilds all decks and shuffles. Resets the deal position.
  void reshuffle() {
    _cards.clear();
    for (var d = 0; d < deckCount; d++) {
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          _cards.add(Card(rank, suit));
        }
      }
    }
    _cards.shuffle(_random);
    _position = 0;
  }

  /// Deals the next card. Throws [StateError] if the shoe is exhausted.
  Card deal() {
    if (_position >= _cards.length) {
      throw StateError('Shoe exhausted; reshuffle before dealing.');
    }
    return _cards[_position++];
  }
}
