import '../models/card.dart';

/// Tracks the Hi-Lo running count and converts it to a true count.
///
/// The running count is the sum of each seen card's [Card.hiLoValue]. The true
/// count normalises it by the number of decks still in the shoe, which is what
/// actually drives bet sizing and strategy deviations.
class HiLoCounter {
  int _runningCount = 0;

  int get runningCount => _runningCount;

  /// Adds one card to the running count.
  void record(Card card) => _runningCount += card.hiLoValue;

  /// Adds several cards to the running count.
  void recordAll(Iterable<Card> cards) {
    for (final c in cards) {
      _runningCount += c.hiLoValue;
    }
  }

  void reset() => _runningCount = 0;

  /// True count = running count / decks remaining.
  ///
  /// When [decksRemaining] is at or below zero the running count is returned
  /// unscaled (a safe fallback for an effectively empty shoe).
  double trueCount(double decksRemaining) {
    if (decksRemaining <= 0) return _runningCount.toDouble();
    return _runningCount / decksRemaining;
  }

  /// True count rounded toward zero to a whole number, the form most counting
  /// systems use for index/deviation decisions.
  int trueCountFloor(double decksRemaining) {
    final tc = trueCount(decksRemaining);
    return tc.truncate();
  }
}
