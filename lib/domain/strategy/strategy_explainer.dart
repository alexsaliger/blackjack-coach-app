import '../models/action.dart';
import '../models/card.dart';
import '../models/hand.dart';
import '../models/rule_set.dart';

/// Produces a short, plain-language reason (German) for why a given
/// basic-strategy [PlayerAction] is correct for a hand against a dealer upcard.
///
/// These are pedagogical rules of thumb built around the two core ideas of
/// basic strategy — the dealer busts often on 2–6 (weak) and usually makes a
/// hand on 7–A (strong) — not a cell-by-cell transcript of the chart.
class StrategyExplainer {
  const StrategyExplainer();

  String explain(
    Hand hand,
    Card dealerUp,
    PlayerAction action,
    RuleSet rules,
  ) {
    final up = dealerUp.rank == Rank.ace ? 11 : dealerUp.rank.baseValue;
    final dealerWeak = up >= 2 && up <= 6;
    final total = hand.total;

    switch (action) {
      case PlayerAction.split:
        if (hand.pairValue == 11) {
          return 'Asse splittet man immer: Aus einer weichen 12 werden zwei '
              'Hände, die je auf 21 zielen.';
        }
        if (hand.pairValue == 8) {
          return 'Achter splittet man immer: 16 ist die schlechteste Hand im '
              'Spiel — zwei frische Hände sind klar besser.';
        }
        if (dealerWeak) {
          return 'Paar gegen eine schwache Dealerkarte (2–6) splitten: Du '
              'bringst zwei Hände ins Spiel und nutzt seine hohe Bust-Gefahr.';
        }
        return 'Dieses Paar splittet man hier, weil zwei getrennte Hände den '
            'besseren Erwartungswert haben als eine gemeinsame.';

      case PlayerAction.doubleDown:
        if (hand.isSoft) {
          return 'Weiche Hand gegen eine schwache Dealerkarte: Verdopple — du '
              'kannst mit einer Karte nicht überkaufen und erhöhst bei Vorteil '
              'den Einsatz.';
        }
        return 'Starke Ausgangshand ($total) gegen eine schwache Dealerkarte: '
            'Verdopple, um bei gutem Erwartungswert mehr zu setzen. Du ziehst '
            'dafür genau eine Karte.';

      case PlayerAction.surrender:
        return 'Deine $total gewinnt gegen diese starke Dealerkarte zu selten. '
            'Gib die Hälfte des Einsatzes auf (Surrender) und begrenze so den '
            'Verlust.';

      case PlayerAction.stand:
        if (hand.isSoft) {
          return 'Deine weiche Hand ist schon stark genug — steh und zwing den '
              'Dealer, selbst eine Hand zu bauen.';
        }
        if (total >= 17) {
          return 'Harte $total: Beim Ziehen überkaufst du zu oft. Steh und '
              'setze auf einen Dealer-Bust.';
        }
        if (dealerWeak) {
          return 'Steh: Der Dealer zeigt 2–6, muss ziehen und geht '
              'überdurchschnittlich oft bust. Riskiere mit deiner $total '
              'keinen eigenen Bust.';
        }
        return 'Steh mit deiner $total.';

      case PlayerAction.hit:
        if (!hand.isSoft && total <= 11) {
          return 'Mit $total kannst du nicht überkaufen — zieh immer, um die '
              'Hand zu verbessern.';
        }
        if (hand.isSoft) {
          return 'Weiche Hand ohne Bust-Risiko: Zieh, um sie weiter zu '
              'verbessern.';
        }
        if (!dealerWeak) {
          return 'Zieh: Der Dealer zeigt 7–A und steht wahrscheinlich auf '
              '17–21. Mit deiner $total verlierst du beim Stehen meist — du '
              'musst verbessern.';
        }
        return 'Zieh, um deine $total zu verbessern.';
    }
  }
}
