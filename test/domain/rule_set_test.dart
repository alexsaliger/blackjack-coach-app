import 'package:coaches_dont_play/domain/models/rule_set.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuleSet JSON', () {
    test('round-trips through toJson/fromJson', () {
      const rules = RuleSet(
        decks: 2,
        dealerHitsSoft17: true,
        doubleAfterSplit: false,
        surrenderAllowed: false,
        resplitAces: true,
        maxSplitHands: 3,
        blackjackPayout: BlackjackPayout.sixToFive,
        penetration: 0.85,
      );
      final restored = RuleSet.fromJson(rules.toJson());
      expect(restored, rules);
    });

    test('fromJson tolerates missing fields (falls back to defaults)', () {
      final r = RuleSet.fromJson({'decks': 8});
      expect(r.decks, 8);
      expect(r, const RuleSet(decks: 8));
    });

    test('equality and hashCode agree', () {
      expect(const RuleSet(), const RuleSet());
      expect(const RuleSet().hashCode, const RuleSet().hashCode);
      expect(const RuleSet(decks: 1) == const RuleSet(decks: 6), isFalse);
    });
  });
}
