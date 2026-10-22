import '../models/action.dart';
import '../models/card.dart';
import '../models/hand.dart';

/// A single true-count index play: against [dealerUp], play [atOrAbove] when
/// the true count is >= [index], otherwise [below].
class Deviation {
  const Deviation({
    required this.isPair,
    required this.isSoft,
    required this.key,
    required this.dealerUp,
    required this.index,
    required this.atOrAbove,
    required this.below,
    required this.name,
  });

  /// Whether this entry matches a pair hand.
  final bool isPair;

  /// Whether this entry matches a soft hand (ignored when [isPair]).
  final bool isSoft;

  /// Pair value when [isPair], otherwise the hard/soft total.
  final int key;

  /// Dealer upcard value (11 = Ace).
  final int dealerUp;

  /// True-count threshold.
  final double index;

  final PlayerAction atOrAbove;
  final PlayerAction below;

  /// Human-readable label for charts and feedback, e.g. "16 v 10".
  final String name;
}

/// Overlays Hi-Lo true-count index plays on top of basic strategy.
///
/// Contains the classic **Illustrious 18** (the 18 highest-value deviations,
/// incl. the insurance decision) and the **Fab 4** late-surrender indices.
/// Indices are the standard published Hi-Lo values for 4–8 deck S17 games and
/// live in [all] as plain data, so they are easy to review and adjust.
class Deviations {
  const Deviations();

  /// Take insurance when the true count reaches this threshold.
  static const double insuranceIndex = 3.0;

  /// Whether to take insurance (or an even-money payout) at [trueCount].
  static bool shouldTakeInsurance(double trueCount) =>
      trueCount >= insuranceIndex;

  /// Illustrious 18 playing deviations (insurance handled separately above).
  static const List<Deviation> illustrious18 = [
    Deviation(isPair: false, isSoft: false, key: 16, dealerUp: 10, index: 0, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '16 v 10'),
    Deviation(isPair: false, isSoft: false, key: 15, dealerUp: 10, index: 4, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '15 v 10'),
    Deviation(isPair: true, isSoft: false, key: 10, dealerUp: 5, index: 5, atOrAbove: PlayerAction.split, below: PlayerAction.stand, name: '10,10 v 5'),
    Deviation(isPair: true, isSoft: false, key: 10, dealerUp: 6, index: 4, atOrAbove: PlayerAction.split, below: PlayerAction.stand, name: '10,10 v 6'),
    Deviation(isPair: false, isSoft: false, key: 10, dealerUp: 10, index: 4, atOrAbove: PlayerAction.doubleDown, below: PlayerAction.hit, name: '10 v 10'),
    Deviation(isPair: false, isSoft: false, key: 12, dealerUp: 3, index: 2, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '12 v 3'),
    Deviation(isPair: false, isSoft: false, key: 12, dealerUp: 2, index: 3, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '12 v 2'),
    Deviation(isPair: false, isSoft: false, key: 11, dealerUp: 11, index: 1, atOrAbove: PlayerAction.doubleDown, below: PlayerAction.hit, name: '11 v A'),
    Deviation(isPair: false, isSoft: false, key: 9, dealerUp: 2, index: 1, atOrAbove: PlayerAction.doubleDown, below: PlayerAction.hit, name: '9 v 2'),
    Deviation(isPair: false, isSoft: false, key: 10, dealerUp: 11, index: 4, atOrAbove: PlayerAction.doubleDown, below: PlayerAction.hit, name: '10 v A'),
    Deviation(isPair: false, isSoft: false, key: 9, dealerUp: 7, index: 3, atOrAbove: PlayerAction.doubleDown, below: PlayerAction.hit, name: '9 v 7'),
    Deviation(isPair: false, isSoft: false, key: 16, dealerUp: 9, index: 5, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '16 v 9'),
    Deviation(isPair: false, isSoft: false, key: 13, dealerUp: 2, index: -1, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '13 v 2'),
    Deviation(isPair: false, isSoft: false, key: 12, dealerUp: 4, index: 0, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '12 v 4'),
    Deviation(isPair: false, isSoft: false, key: 12, dealerUp: 5, index: -2, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '12 v 5'),
    Deviation(isPair: false, isSoft: false, key: 12, dealerUp: 6, index: -1, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '12 v 6'),
    Deviation(isPair: false, isSoft: false, key: 13, dealerUp: 3, index: -2, atOrAbove: PlayerAction.stand, below: PlayerAction.hit, name: '13 v 3'),
  ];

  /// Fab 4 late-surrender indices (surrender at/above the count, else hit).
  static const List<Deviation> fab4 = [
    Deviation(isPair: false, isSoft: false, key: 14, dealerUp: 10, index: 3, atOrAbove: PlayerAction.surrender, below: PlayerAction.hit, name: '14 v 10'),
    Deviation(isPair: false, isSoft: false, key: 15, dealerUp: 9, index: 2, atOrAbove: PlayerAction.surrender, below: PlayerAction.hit, name: '15 v 9'),
    Deviation(isPair: false, isSoft: false, key: 15, dealerUp: 10, index: 0, atOrAbove: PlayerAction.surrender, below: PlayerAction.hit, name: '15 v 10'),
    Deviation(isPair: false, isSoft: false, key: 15, dealerUp: 11, index: 1, atOrAbove: PlayerAction.surrender, below: PlayerAction.hit, name: '15 v A'),
  ];

  /// All index plays combined.
  static const List<Deviation> all = [...illustrious18, ...fab4];

  /// Finds the index play matching [player] vs [dealerUp], if any.
  Deviation? lookup(Hand player, Card dealerUp) {
    final up = dealerUp.rank == Rank.ace ? 11 : dealerUp.rank.baseValue;
    final key = player.isPair ? player.pairValue! : player.total;
    for (final d in all) {
      if (d.dealerUp != up) continue;
      if (d.isPair != player.isPair) continue;
      if (d.key != key) continue;
      if (!d.isPair && d.isSoft != player.isSoft) continue;
      return d;
    }
    return null;
  }

  /// The count-adjusted action. Returns [basicAction] when no index play
  /// applies, or when the deviation would require doubling/splitting/
  /// surrendering on a hand that can no longer do so.
  PlayerAction recommend(
    Hand player,
    Card dealerUp,
    double trueCount,
    PlayerAction basicAction,
  ) {
    final d = lookup(player, dealerUp);
    if (d == null) return basicAction;

    final action = trueCount >= d.index ? d.atOrAbove : d.below;

    final needsInitial = action == PlayerAction.doubleDown ||
        action == PlayerAction.split ||
        action == PlayerAction.surrender;
    if (needsInitial && !player.isInitial) return basicAction;

    return action;
  }
}
