import '../models/action.dart';
import '../models/card.dart';
import '../models/hand.dart';
import '../models/rule_set.dart';
import 'strategy_tables.dart';

/// Computes the textbook basic-strategy play for a hand against a dealer
/// upcard, honouring the active [RuleSet]. This is count-independent; the
/// [Deviations] layer overlays true-count adjustments on top.
class BasicStrategy {
  const BasicStrategy(this.rules);

  final RuleSet rules;

  /// The correct basic-strategy action for [player] versus [dealerUp].
  PlayerAction recommend(Hand player, Card dealerUp) {
    final up = dealerUp.rank == Rank.ace ? 11 : dealerUp.rank.baseValue;
    final chart = rules.dealerHitsSoft17 ? StrategyTables.h17 : StrategyTables.s17;

    // Doubling and surrender are only possible on the opening two-card hand.
    final canDouble = player.isInitial;
    final canSurrender = rules.surrenderAllowed && player.isInitial;
    final canSplit = player.isPair && rules.maxSplitHands > 1;

    StrategyCode? code;
    if (player.isPair) {
      code = chart.pairs[player.pairValue]?[up];
    }
    if (code == null) {
      final table = player.isSoft ? chart.soft : chart.hard;
      code = table[player.total]?[up];
    }

    if (code == null) {
      // Outside the tabulated range: stand on hard 17+, otherwise hit.
      return player.total >= 17 ? PlayerAction.stand : PlayerAction.hit;
    }

    return StrategyTables.resolve(
      code,
      canDouble: canDouble,
      canSurrender: canSurrender,
      canSplit: canSplit,
      dasAllowed: rules.doubleAfterSplit,
    );
  }
}
