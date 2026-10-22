import '../models/hand.dart';
import '../models/rule_set.dart';
import 'shoe.dart';

/// Plays out the dealer's hand per the rules: hit below 17, and hit soft 17
/// only when the rule set says so (H17).
class Dealer {
  const Dealer(this.rules);

  final RuleSet rules;

  /// Draws cards into [hand] from [shoe] until the dealer must stand.
  void playOut(Hand hand, Shoe shoe) {
    while (shouldHit(hand)) {
      hand.add(shoe.deal());
    }
  }

  /// Whether the dealer is required to draw another card on [hand].
  bool shouldHit(Hand hand) {
    final total = hand.total;
    if (total < 17) return true;
    if (total == 17 && hand.isSoft && rules.dealerHitsSoft17) return true;
    return false;
  }
}
