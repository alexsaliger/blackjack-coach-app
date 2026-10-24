import 'dart:math';

import 'package:coaches_dont_play/domain/engine/deviation_scenario_generator.dart';
import 'package:coaches_dont_play/domain/strategy/deviations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviationScenarioGenerator', () {
    const dev = Deviations();

    test('scenario hand/upcard resolves to its carried deviation', () {
      final gen = DeviationScenarioGenerator(random: Random(3));
      for (var i = 0; i < 300; i++) {
        final s = gen.next();
        final found = dev.lookup(s.player, s.dealerUp);
        expect(found, isNotNull);
        expect(found!.name, s.deviation.name);
        expect(found.index, s.deviation.index);

        if (s.deviation.isPair) {
          expect(s.player.isPair, isTrue);
          expect(s.player.pairValue, s.deviation.key);
        } else {
          expect(s.player.isPair, isFalse);
          expect(s.player.isSoft, isFalse);
          expect(s.player.total, s.deviation.key);
        }
      }
    });

    test('true count is generated within ±3 of the deviation index', () {
      final gen = DeviationScenarioGenerator(random: Random(9));
      for (var i = 0; i < 100; i++) {
        final s = gen.next();
        expect((s.trueCount - s.deviation.index).abs() <= 3, isTrue);
      }
    });

    test('grading agrees with the recommendation at and below the index', () {
      final gen = DeviationScenarioGenerator(random: Random(11));
      for (var i = 0; i < 100; i++) {
        final s = gen.next();
        // Basic action is irrelevant when a deviation matches; pass hit.
        final atOrAbove = dev.recommend(
            s.player, s.dealerUp, s.deviation.index, s.deviation.below);
        expect(atOrAbove, s.deviation.atOrAbove);
        final below = dev.recommend(
            s.player, s.dealerUp, s.deviation.index - 1, s.deviation.atOrAbove);
        expect(below, s.deviation.below);
      }
    });
  });
}
