import 'package:coaches_dont_play/domain/strategy/deviation_explainer.dart';
import 'package:coaches_dont_play/domain/strategy/deviations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const explainer = DeviationExplainer();

  Deviation byName(String name) =>
      Deviations.all.firstWhere((d) => d.name == name);

  test('below the index, it points back to basic strategy', () {
    final d = byName('16 v 10'); // index 0, stand at/above, hit below
    final reason = explainer.explain(d, -2);
    expect(reason, contains('Basic'));
    expect(reason.toLowerCase(), contains('lohnt sich noch nicht'));
  });

  test('at/above a stand index, it explains the ten-rich shoe', () {
    final d = byName('16 v 10');
    final reason = explainer.explain(d, 1);
    expect(reason.toLowerCase(), contains('zehner'));
    expect(reason.toLowerCase(), contains('bust'));
  });

  test('double and surrender index plays get fitting reasons', () {
    expect(explainer.explain(byName('11 v A'), 2).toLowerCase(),
        contains('verdopple'));
    expect(explainer.explain(byName('14 v 10'), 4).toLowerCase(),
        contains('surrender'));
  });
}
