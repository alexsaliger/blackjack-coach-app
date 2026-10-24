import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analysis/house_edge.dart';
import '../../domain/models/rule_set.dart';
import '../../state/settings_providers.dart';
import '../help_texts.dart';
import '../widgets/info_button.dart';

/// Lets the player configure the table [RuleSet] and shows the resulting house
/// edge, updated live. Changes are persisted immediately.
class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  static const _calc = HouseEdgeCalculator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(ruleSetProvider);
    final controller = ref.read(ruleSetProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final edge = _calc.compute(rules);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regeln & House Edge'),
        actions: const [InfoButton(HelpTexts.rules)],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionTitle(context, 'Decks'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final d in const [1, 2, 4, 6, 8])
                      ChoiceChip(
                        label: Text('$d'),
                        selected: rules.decks == d,
                        onSelected: (_) =>
                            controller.update((r) => r.copyWith(decks: d)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                _sectionTitle(context, 'Blackjack-Auszahlung'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in BlackjackPayout.values)
                      ChoiceChip(
                        label: Text(p.label),
                        selected: rules.blackjackPayout == p,
                        onSelected: (_) => controller
                            .update((r) => r.copyWith(blackjackPayout: p)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dealer zieht auf Soft 17 (H17)'),
                  subtitle: const Text('Aus = S17 (Dealer steht)'),
                  value: rules.dealerHitsSoft17,
                  onChanged: (v) =>
                      controller.update((r) => r.copyWith(dealerHitsSoft17: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Double after Split (DAS)'),
                  value: rules.doubleAfterSplit,
                  onChanged: (v) =>
                      controller.update((r) => r.copyWith(doubleAfterSplit: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Late Surrender'),
                  value: rules.surrenderAllowed,
                  onChanged: (v) =>
                      controller.update((r) => r.copyWith(surrenderAllowed: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Resplit Aces'),
                  value: rules.resplitAces,
                  onChanged: (v) =>
                      controller.update((r) => r.copyWith(resplitAces: v)),
                ),

                _sectionTitle(context, 'Penetration'),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 0.5,
                        max: 0.9,
                        divisions: 8,
                        value: rules.penetration.clamp(0.5, 0.9),
                        label: '${(rules.penetration * 100).round()}%',
                        onChanged: (v) => controller
                            .update((r) => r.copyWith(penetration: v)),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text('${(rules.penetration * 100).round()}%',
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _sectionTitle(context, 'House Edge'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${edge.totalPercent >= 0 ? '' : '+'}'
                          '${edge.totalPercent.toStringAsFixed(2)} %',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: scheme.secondary,
                          ),
                        ),
                        Text(
                          'Hausvorteil bei perfekter Basic Strategy',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        const Divider(height: 28),
                        for (final c in edge.components)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(c.label)),
                                Text(
                                  '${c.percent >= 0 ? '+' : ''}'
                                  '${c.percent.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: c.percent > 0
                                        ? scheme.error
                                        : (c.percent < 0
                                            ? const Color(0xFF66BB6A)
                                            : scheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
}
