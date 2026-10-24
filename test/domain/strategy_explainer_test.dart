import 'package:coaches_dont_play/domain/models/action.dart';
import 'package:coaches_dont_play/domain/models/card.dart';
import 'package:coaches_dont_play/domain/models/hand.dart';
import 'package:coaches_dont_play/domain/models/rule_set.dart';
import 'package:coaches_dont_play/domain/strategy/strategy_explainer.dart';
import 'package:flutter_test/flutter_test.dart';

Card _c(Rank r) => Card(r, Suit.spades);
Hand _hand(List<Rank> ranks) => Hand(ranks.map(_c).toList());

void main() {
  const explainer = StrategyExplainer();
  const rules = RuleSet();

  String explain(List<Rank> p, Rank up, PlayerAction a) =>
      explainer.explain(_hand(p), _c(up), a, rules);

  test('gives a non-empty reason for every action', () {
    expect(explain([Rank.eight, Rank.eight], Rank.ten, PlayerAction.split),
        isNotEmpty);
    expect(explain([Rank.six, Rank.five], Rank.five, PlayerAction.doubleDown),
        isNotEmpty);
    expect(explain([Rank.ten, Rank.six], Rank.ten, PlayerAction.surrender),
        isNotEmpty);
    expect(explain([Rank.ten, Rank.two], Rank.six, PlayerAction.stand),
        isNotEmpty);
    expect(explain([Rank.ten, Rank.six], Rank.ten, PlayerAction.hit),
        isNotEmpty);
  });

  test('mentions the weak-dealer idea when standing on a stiff vs 2–6', () {
    final reason =
        explain([Rank.ten, Rank.six], Rank.six, PlayerAction.stand);
    expect(reason.toLowerCase(), contains('bust'));
  });

  test('aces and eights get the "always split" reasoning', () {
    expect(explain([Rank.ace, Rank.ace], Rank.six, PlayerAction.split),
        contains('Asse'));
    expect(explain([Rank.eight, Rank.eight], Rank.ten, PlayerAction.split),
        contains('16'));
  });
}
