import 'dart:math';

import 'package:coaches_dont_play/domain/analysis/house_edge.dart';
import 'package:coaches_dont_play/domain/counting/hilo_counter.dart';
import 'package:coaches_dont_play/domain/engine/dealer.dart';
import 'package:coaches_dont_play/domain/engine/shoe.dart';
import 'package:coaches_dont_play/domain/models/action.dart';
import 'package:coaches_dont_play/domain/models/card.dart';
import 'package:coaches_dont_play/domain/models/hand.dart';
import 'package:coaches_dont_play/domain/models/rule_set.dart';
import 'package:coaches_dont_play/domain/strategy/basic_strategy.dart';
import 'package:coaches_dont_play/domain/strategy/deviations.dart';
import 'package:flutter_test/flutter_test.dart';

// --- helpers ---------------------------------------------------------------

Card c(Rank r) => Card(r, Suit.spades);
Hand hand(List<Rank> ranks) => Hand(ranks.map(c).toList());

void main() {
  group('Card / Hi-Lo values', () {
    test('low cards 2–6 count +1', () {
      for (final r in [Rank.two, Rank.three, Rank.four, Rank.five, Rank.six]) {
        expect(c(r).hiLoValue, 1, reason: '$r');
      }
    });
    test('neutral cards 7–9 count 0', () {
      for (final r in [Rank.seven, Rank.eight, Rank.nine]) {
        expect(c(r).hiLoValue, 0, reason: '$r');
      }
    });
    test('high cards 10–A count -1', () {
      for (final r in [Rank.ten, Rank.jack, Rank.queen, Rank.king, Rank.ace]) {
        expect(c(r).hiLoValue, -1, reason: '$r');
      }
    });
  });

  group('Hand', () {
    test('hard total', () {
      expect(hand([Rank.ten, Rank.seven]).total, 17);
      expect(hand([Rank.ten, Rank.six, Rank.five]).total, 21);
    });
    test('ace counts as 11 when safe (soft), drops to 1 when needed', () {
      final soft = hand([Rank.ace, Rank.six]); // soft 17
      expect(soft.total, 17);
      expect(soft.isSoft, isTrue);
      final hard = hand([Rank.ace, Rank.six, Rank.ten]); // 17 hard
      expect(hard.total, 17);
      expect(hard.isSoft, isFalse);
    });
    test('multiple aces', () {
      final h = hand([Rank.ace, Rank.ace]); // soft 12
      expect(h.total, 12);
      expect(h.isSoft, isTrue);
    });
    test('blackjack vs 21', () {
      expect(hand([Rank.ace, Rank.king]).isBlackjack, isTrue);
      expect(hand([Rank.seven, Rank.seven, Rank.seven]).isBlackjack, isFalse);
      expect(hand([Rank.seven, Rank.seven, Rank.seven]).total, 21);
    });
    test('bust', () {
      expect(hand([Rank.ten, Rank.ten, Rank.five]).isBust, isTrue);
    });
    test('pairs by value (10-K is a pair of tens)', () {
      expect(hand([Rank.ten, Rank.king]).isPair, isTrue);
      expect(hand([Rank.ten, Rank.king]).pairValue, 10);
      expect(hand([Rank.ace, Rank.ace]).pairValue, 11);
      expect(hand([Rank.ten, Rank.nine]).isPair, isFalse);
    });
  });

  group('Shoe', () {
    test('contains deckCount * 52 cards', () {
      final shoe = Shoe(deckCount: 6, random: Random(1));
      expect(shoe.totalCards, 312);
      expect(shoe.cardsRemaining, 312);
    });
    test('Hi-Lo values over a full shoe sum to zero (balanced system)', () {
      final shoe = Shoe(deckCount: 2, random: Random(7));
      var sum = 0;
      while (shoe.cardsRemaining > 0) {
        sum += shoe.deal().hiLoValue;
      }
      expect(sum, 0);
    });
    test('same seed deals the same order (deterministic)', () {
      final a = Shoe(deckCount: 1, random: Random(42));
      final b = Shoe(deckCount: 1, random: Random(42));
      for (var i = 0; i < 52; i++) {
        expect(a.deal(), b.deal());
      }
    });
    test('needsReshuffle trips at penetration', () {
      final shoe = Shoe(deckCount: 1, penetration: 0.5, random: Random(3));
      expect(shoe.needsReshuffle, isFalse);
      for (var i = 0; i < 26; i++) {
        shoe.deal();
      }
      expect(shoe.needsReshuffle, isTrue);
    });
    test('dealing past the end throws', () {
      final shoe = Shoe(deckCount: 1, penetration: 1.0, random: Random(3));
      for (var i = 0; i < 52; i++) {
        shoe.deal();
      }
      expect(shoe.deal, throwsStateError);
    });
  });

  group('HiLoCounter', () {
    test('running count accumulates', () {
      final counter = HiLoCounter();
      counter.recordAll([c(Rank.five), c(Rank.six), c(Rank.king)]); // +1+1-1
      expect(counter.runningCount, 1);
    });
    test('true count divides by decks remaining', () {
      final counter = HiLoCounter()..recordAll(List.filled(6, c(Rank.two)));
      expect(counter.runningCount, 6);
      expect(counter.trueCount(3.0), closeTo(2.0, 1e-9));
      expect(counter.trueCountFloor(4.0), 1); // 6/4 = 1.5 -> 1
    });
  });

  group('Dealer', () {
    test('S17: stands on soft 17, hits hard 16', () {
      final d = Dealer(const RuleSet(dealerHitsSoft17: false));
      expect(d.shouldHit(hand([Rank.ace, Rank.six])), isFalse); // soft 17
      expect(d.shouldHit(hand([Rank.ten, Rank.six])), isTrue); // hard 16
      expect(d.shouldHit(hand([Rank.ten, Rank.seven])), isFalse); // hard 17
    });
    test('H17: hits soft 17', () {
      final d = Dealer(const RuleSet(dealerHitsSoft17: true));
      expect(d.shouldHit(hand([Rank.ace, Rank.six])), isTrue);
    });
    test('playOut draws until standing', () {
      final d = Dealer(const RuleSet(dealerHitsSoft17: false));
      final shoe = Shoe(deckCount: 6, random: Random(5));
      final h = Hand([shoe.deal()]);
      d.playOut(h, shoe);
      expect(h.total, greaterThanOrEqualTo(17));
    });
  });

  group('BasicStrategy (S17, DAS, surrender)', () {
    const strat = BasicStrategy(RuleSet());
    PlayerAction rec(List<Rank> p, Rank up) => strat.recommend(hand(p), c(up));

    test('hard 16 vs 10 -> surrender (allowed)', () {
      expect(rec([Rank.ten, Rank.six], Rank.ten), PlayerAction.surrender);
    });
    test('hard 12 vs 6 -> stand', () {
      expect(rec([Rank.ten, Rank.two], Rank.six), PlayerAction.stand);
    });
    test('hard 11 vs 6 -> double', () {
      expect(rec([Rank.six, Rank.five], Rank.six), PlayerAction.doubleDown);
    });
    test('hard 11 vs A -> hit (S17)', () {
      expect(rec([Rank.six, Rank.five], Rank.ace), PlayerAction.hit);
    });
    test('soft 18 (A,7) vs 9 -> hit', () {
      expect(rec([Rank.ace, Rank.seven], Rank.nine), PlayerAction.hit);
    });
    test('soft 18 (A,7) vs 3 -> double', () {
      expect(rec([Rank.ace, Rank.seven], Rank.three), PlayerAction.doubleDown);
    });
    test('pair 8,8 vs 10 -> split', () {
      expect(rec([Rank.eight, Rank.eight], Rank.ten), PlayerAction.split);
    });
    test('pair A,A -> split', () {
      expect(rec([Rank.ace, Rank.ace], Rank.six), PlayerAction.split);
    });
    test('pair 10,10 -> stand', () {
      expect(rec([Rank.ten, Rank.king], Rank.six), PlayerAction.stand);
    });
    test('pair 5,5 vs 6 -> double (treated as hard 10)', () {
      expect(rec([Rank.five, Rank.five], Rank.six), PlayerAction.doubleDown);
    });
    test('double downgrades to hit on a 3-card hand', () {
      // 3-card hard 11 cannot double.
      expect(rec([Rank.four, Rank.four, Rank.three], Rank.six),
          PlayerAction.hit);
    });
  });

  group('BasicStrategy (H17 overrides)', () {
    const strat = BasicStrategy(RuleSet(dealerHitsSoft17: true));
    PlayerAction rec(List<Rank> p, Rank up) => strat.recommend(hand(p), c(up));

    test('hard 11 vs A -> double (H17)', () {
      expect(rec([Rank.six, Rank.five], Rank.ace), PlayerAction.doubleDown);
    });
    test('soft 19 (A,8) vs 6 -> double (H17)', () {
      expect(rec([Rank.ace, Rank.eight], Rank.six), PlayerAction.doubleDown);
    });
  });

  group('Deviations (Illustrious 18 / Fab 4)', () {
    const dev = Deviations();
    const basic = BasicStrategy(RuleSet(surrenderAllowed: false));

    PlayerAction rec(List<Rank> p, Rank up, double tc) {
      final h = hand(p);
      final up2 = c(up);
      return dev.recommend(h, up2, tc, basic.recommend(h, up2));
    }

    test('16 v 10: stand at TC 0, hit below', () {
      expect(rec([Rank.ten, Rank.six], Rank.ten, 0), PlayerAction.stand);
      expect(rec([Rank.ten, Rank.six], Rank.ten, -1), PlayerAction.hit);
    });
    test('12 v 3: stand at TC 2, hit below', () {
      expect(rec([Rank.ten, Rank.two], Rank.three, 2), PlayerAction.stand);
      expect(rec([Rank.ten, Rank.two], Rank.three, 1), PlayerAction.hit);
    });
    test('insurance threshold at TC 3', () {
      expect(Deviations.shouldTakeInsurance(3), isTrue);
      expect(Deviations.shouldTakeInsurance(2.9), isFalse);
    });
    test('Fab 4: 14 v 10 surrenders at TC 3', () {
      const stratLS = BasicStrategy(RuleSet());
      final h = hand([Rank.ten, Rank.four]);
      final up = c(Rank.ten);
      expect(dev.recommend(h, up, 3, stratLS.recommend(h, up)),
          PlayerAction.surrender);
    });
    test('no matching deviation returns the basic action', () {
      // hard 19 (10,9) vs 6: no index play -> stays stand.
      expect(rec([Rank.ten, Rank.nine], Rank.six, 5), PlayerAction.stand);
    });
  });

  group('HouseEdgeCalculator', () {
    const calc = HouseEdgeCalculator();

    test('reference 6-deck S17 DAS surrender edge is modest', () {
      final edge = calc.edgePercent(const RuleSet());
      // 0.54 base - 0.14 DAS - 0.08 surrender = 0.32
      expect(edge, closeTo(0.32, 1e-9));
    });
    test('H17 increases the edge', () {
      final s17 = calc.edgePercent(const RuleSet());
      final h17 = calc.edgePercent(const RuleSet(dealerHitsSoft17: true));
      expect(h17 - s17, closeTo(0.22, 1e-9));
    });
    test('6:5 blackjack is a big jump', () {
      final threeTwo = calc.edgePercent(const RuleSet());
      final sixFive = calc.edgePercent(
          const RuleSet(blackjackPayout: BlackjackPayout.sixToFive));
      expect(sixFive - threeTwo, closeTo(1.39, 1e-9));
    });
    test('single deck lowers the edge vs six decks', () {
      expect(calc.edgePercent(const RuleSet(decks: 1)),
          lessThan(calc.edgePercent(const RuleSet(decks: 6))));
    });
  });
}
