import '../models/action.dart';
import 'deviations.dart';

/// Explains (in German) why a Hi-Lo index play applies — or doesn't — at a
/// given true count. The core idea: a high true count means many tens and aces
/// are still in the shoe, which shifts several close decisions.
class DeviationExplainer {
  const DeviationExplainer();

  String explain(Deviation d, double trueCount) {
    final idx = d.index.toStringAsFixed(0);
    final tc = trueCount.toStringAsFixed(0);
    final met = trueCount >= d.index;

    if (!met) {
      return 'True Count $tc liegt unter dem Index ($idx). Die Abweichung '
          'lohnt sich noch nicht — spiel ${d.below.label} wie in der Basic '
          'Strategy.';
    }

    switch (d.atOrAbove) {
      case PlayerAction.stand:
        return 'Ab True Count ≥ $idx sind überdurchschnittlich viele Zehner im '
            'Schlitten. Beim Ziehen überkaufst du öfter, und der Dealer geht '
            'eher bust — darum steh (${d.name}).';
      case PlayerAction.doubleDown:
        return 'Ab True Count ≥ $idx liegen viele Zehner bereit — du triffst '
            'eher eine starke Hand. Verdopple, um den Vorteil auszunutzen '
            '(${d.name}).';
      case PlayerAction.split:
        return 'Nur bei sehr hohem Count (≥ $idx) lohnt es sich, Zehner gegen '
            'eine schwache Dealerkarte zu splitten: zwei Hände mit ~20 gegen '
            'einen bust-gefährdeten Dealer.';
      case PlayerAction.surrender:
        final hand = d.name.split(' ').first;
        return 'Ab True Count ≥ $idx gewinnt $hand gegen diese starke Karte '
            'noch seltener — gib auf (Surrender) und spar den halben Einsatz.';
      case PlayerAction.hit:
        return 'Ab True Count ≥ $idx ist Ziehen hier die bessere Wahl '
            '(${d.name}).';
    }
  }
}
